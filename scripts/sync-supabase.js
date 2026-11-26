const fs = require("fs");
const envContent = fs.readFileSync("apps/api/.env", "utf-8");
let dbUrl = "";
for (const line of envContent.split("\n")) {
  if (line.startsWith("DATABASE_URL=")) {
    dbUrl = line.substring("DATABASE_URL=".length).trim();
  }
}

const path = require("path");
const apiDir = path.resolve(__dirname, "../apps/api");
const { DataSource } = require(path.join(apiDir, "node_modules/typeorm"));
const entities = require(path.join(apiDir, "dist/database/index.js"));
console.log("Entities count:", entities.AllEntities.length);

const ds = new DataSource({
  type: "postgres",
  url: dbUrl,
  entities: entities.AllEntities,
  synchronize: true,
  ssl: { rejectUnauthorized: false },
});

async function main() {
  try {
    await ds.initialize();
    console.log(">>> SUCCESS: Connected and Synchronized schema to Supabase!");
    const tables = await ds.query(
      "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;",
    );
    console.log(
      ">>> Created tables in Supabase:",
      tables.map((t) => t.table_name),
    );

    // Check if initial seed needed
    const {
      runDatabaseSeed,
    } = require(path.join(apiDir, "dist/database/seeds/initial.seed.js"));
    console.log(">>> Running initial database seed...");
    await runDatabaseSeed(ds);
    console.log(">>> Database Seed completed successfully!");

    await ds.destroy();
  } catch (err) {
    console.error(">>> Error:", err);
    process.exit(1);
  }
}

main();
