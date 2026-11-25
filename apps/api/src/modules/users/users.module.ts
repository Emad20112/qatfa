import { Module } from "@nestjs/common";
import { UsersService } from "./users.service";
import { UsersController } from "./users.controller";
import { User } from "../../database/entities/user.entity";
import { InMemoryDatabaseModule } from "../../database/in-memory-database.module";

@Module({
  imports: [InMemoryDatabaseModule.forFeature([User])],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}
