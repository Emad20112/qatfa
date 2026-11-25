import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from "@nestjs/common";
import { AuthGuard } from "@nestjs/passport";
import { AppUpdateType, Currency, StockStatus, UserRole } from "@qatfa/shared-types";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { Public, Roles } from "../../common/decorators/roles.decorator";
import { RolesGuard } from "../../common/guards/roles.guard";
import { User } from "../../database/entities/user.entity";
import { AdminService } from "./admin.service";

@Controller("admin")
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Public()
  @Get("auth/status")
  getAuthStatus() {
    return this.adminService.getAuthStatus();
  }

  @Public()
  @Post("auth/claim")
  @HttpCode(HttpStatus.OK)
  claimAdmin(@Body("password") password: string) {
    return this.adminService.claimAdminAccount(password);
  }

  @Public()
  @Post("auth/login")
  @HttpCode(HttpStatus.OK)
  loginAdmin(@Body("password") password: string) {
    return this.adminService.loginAdmin(password);
  }

  @UseGuards(AuthGuard("jwt"), RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.MODERATOR)
  @Get("dashboard")
  getDashboard(@Query("range") range?: string) {
    return this.adminService.getDashboardSummary(range);
  }

  @UseGuards(AuthGuard("jwt"), RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.MODERATOR)
  @Get("verifications")
  getVerifications(
    @Query("search") search?: string,
    @Query("status") status?: string,
    @Query("type") type?: string,
    @Query("page") page?: string,
    @Query("limit") limit?: string,
  ) {
    return this.adminService.getVerifications({
      search,
      status,
      type,
      page,
      limit,
    });
  }

  @UseGuards(AuthGuard("jwt"), RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.MODERATOR)
  @Patch("verifications/:id")
  updateVerification(
    @Param("id") id: string,
    @Body()
    body: {
      action: "APPROVE" | "REJECT" | "RE_REVIEW" | "REQUEST_INFO";
      notes?: string;
    },
    @CurrentUser() user: User,
  ) {
    return this.adminService.updateVerificationStatus(
      id,
      body.action,
      user.fullName,
      body.notes,
    );
  }

  @UseGuards(AuthGuard("jwt"), RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.MODERATOR)
  @Get("users")
  getUsers(
    @Query("search") search?: string,
    @Query("role") role?: string,
    @Query("status") status?: string,
  ) {
    return this.adminService.getUsers({ search, role, status });
  }

  @UseGuards(AuthGuard("jwt"), RolesGuard)
  @Roles(UserRole.ADMIN)
  @Patch("users/:id")
  updateUser(
    @Param("id") id: string,
    @Body() body: { isActive?: boolean; role?: UserRole; fullName?: string },
    @CurrentUser() user: User,
  ) {
    return this.adminService.updateUser(id, body, user.fullName);
  }

  @UseGuards(AuthGuard("jwt"), RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.MODERATOR)
  @Get("sellers")
  getSellers(
    @Query("search") search?: string,
    @Query("verified") verified?: string,
  ) {
    return this.adminService.getSellers({ search, verified });
  }

  @UseGuards(AuthGuard("jwt"), RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.MODERATOR)
  @Patch("sellers/:id")
  updateSeller(
    @Param("id") id: string,
    @Body()
    body: {
      isVerifiedBadge?: boolean;
      isOpenNow?: boolean;
      stallNumber?: string;
      stallLandmark?: string;
    },
    @CurrentUser() user: User,
  ) {
    return this.adminService.updateSeller(id, body, user.fullName);
  }

  @UseGuards(AuthGuard("jwt"), RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.MODERATOR)
  @Get("geo")
  getGeoOverview() {
    return this.adminService.getGeoOverview();
  }

  @UseGuards(AuthGuard("jwt"), RolesGuard)
  @Roles(UserRole.ADMIN)
  @Post("geo/governorates")
  createGovernorate(
    @Body()
    body: { nameAr: string; nameEn?: string; defaultCurrency: Currency },
    @CurrentUser() user: User,
  ) {
    return this.adminService.createGovernorate(body, user.fullName);
  }

  @UseGuards(AuthGuard("jwt"), RolesGuard)
  @Roles(UserRole.ADMIN)
  @Post("geo/markets")
  createMarket(
    @Body()
    body: {
      districtId: number;
      nameAr: string;
      nameEn?: string;
      centerLatitude?: number;
      centerLongitude?: number;
    },
    @CurrentUser() user: User,
  ) {
    return this.adminService.createMarket(body, user.fullName);
  }

  @UseGuards(AuthGuard("jwt"), RolesGuard)
  @Roles(UserRole.ADMIN)
  @Patch("geo/markets/:id")
  toggleMarket(
    @Param("id") id: string,
    @Body("isActive") isActive: boolean,
    @CurrentUser() user: User,
  ) {
    return this.adminService.toggleMarket(
      parseInt(id, 10),
      isActive,
      user.fullName,
    );
  }

  @UseGuards(AuthGuard("jwt"), RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.MODERATOR)
  @Get("bookings")
  getBookings(
    @Query("search") search?: string,
    @Query("status") status?: string,
  ) {
    return this.adminService.getBookings({ search, status });
  }

  @UseGuards(AuthGuard("jwt"), RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.MODERATOR)
  @Patch("bookings/:id")
  updateBooking(
    @Param("id") id: string,
    @Body()
    body: {
      bookingStatus?: "CONFIRMED" | "PENDING" | "COMPLETED" | "CANCELLED";
      stockStatus?: StockStatus;
    },
    @CurrentUser() user: User,
  ) {
    return this.adminService.updateBookingStatus(id, body, user.fullName);
  }

  @UseGuards(AuthGuard("jwt"), RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.MODERATOR)
  @Get("reports")
  getReports(
    @Query("search") search?: string,
    @Query("status") status?: string,
  ) {
    return this.adminService.getReports({ search, status });
  }

  @UseGuards(AuthGuard("jwt"), RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.MODERATOR)
  @Patch("reports/:id")
  moderateReport(
    @Param("id") id: string,
    @Body()
    body: {
      action:
        | "START_REVIEW"
        | "HIDE_OFFER"
        | "WARN_SELLER"
        | "BAN_SELLER"
        | "DISMISS"
        | "RESOLVE";
      notes?: string;
    },
    @CurrentUser() user: User,
  ) {
    return this.adminService.moderateReport(id, body, user.fullName);
  }

  @UseGuards(AuthGuard("jwt"), RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.MODERATOR)
  @Get("analytics")
  getAnalytics(@Query("range") range?: string) {
    return this.adminService.getAnalytics(range);
  }

  @UseGuards(AuthGuard("jwt"), RolesGuard)
  @Roles(UserRole.ADMIN)
  @Get("settings")
  getSettings() {
    return this.adminService.getSystemSettings();
  }

  @UseGuards(AuthGuard("jwt"), RolesGuard)
  @Roles(UserRole.ADMIN)
  @Patch("settings")
  updateSettings(
    @Body()
    body: {
      latestVersion?: string;
      latestBuildNumber?: number;
      minSupportedVersion?: string;
      minSupportedBuildNumber?: number;
      updateType?: AppUpdateType;
      downloadUrl?: string;
      telegramChannelUrl?: string;
      releaseNotes?: string;
    },
    @CurrentUser() user: User,
  ) {
    return this.adminService.updateSystemSettings(body, user.fullName);
  }

  @UseGuards(AuthGuard("jwt"), RolesGuard)
  @Roles(UserRole.ADMIN)
  @Post("notifications/broadcast")
  sendBroadcast(
    @Body()
    body: {
      title: string;
      body: string;
      audience: "ALL" | "CUSTOMERS" | "SELLERS" | "GOVERNORATE";
      deepLink?: string;
    },
    @CurrentUser() user: User,
  ) {
    return this.adminService.dispatchBroadcast(body, user.fullName);
  }

  @UseGuards(AuthGuard("jwt"), RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.MODERATOR)
  @Get("audit-logs")
  getAuditLogs(
    @Query("search") search?: string,
    @Query("badge") badge?: string,
  ) {
    return this.adminService.getAuditLogs({ search, badge });
  }

  @UseGuards(AuthGuard("jwt"), RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.MODERATOR)
  @Get("support")
  getSupportTickets(
    @Query("search") search?: string,
    @Query("status") status?: string,
  ) {
    return this.adminService.getSupportTickets({ search, status });
  }

  @UseGuards(AuthGuard("jwt"), RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.MODERATOR)
  @Patch("support/:id")
  updateSupportTicket(
    @Param("id") id: string,
    @Body()
    body: { status?: "OPEN" | "IN_PROGRESS" | "RESOLVED"; reply?: string },
    @CurrentUser() user: User,
  ) {
    return this.adminService.updateSupportTicket(id, body, user.fullName);
  }
}
