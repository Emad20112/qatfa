import { Controller, Get, Param, ParseIntPipe } from "@nestjs/common";
import { GeoService } from "./geo.service";
import { Public } from "../../common/decorators/roles.decorator";

@Controller("geo")
export class GeoController {
  constructor(private readonly geoService: GeoService) {}

  @Public()
  @Get("tree")
  async getTree() {
    return this.geoService.getTree();
  }

  @Public()
  @Get("markets/:id/map")
  async getMarketMap(@Param("id", ParseIntPipe) id: number) {
    return this.geoService.getMarketMap(id);
  }
}
