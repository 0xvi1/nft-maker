const fs = require("fs");
const path = require("path");
const esbuild = require("esbuild");
const sveltePlugin = require("esbuild-svelte");
const liveServer = require("live-server");
const { sassPlugin } = require("esbuild-sass-plugin");

function showUsage() {
  console.log("🔴  USAGE");
  console.log("node esbuild.js dev");
  console.log("or...");
  console.log("node esbuild.js prod");
  process.exit(0);
}

if (process.argv.length < 3) {
  showUsage();
}

if (!["dev", "prod"].includes(process.argv[2])) {
  showUsage();
}

// production mode, or not
const isProduction = process.argv[2] === "prod";

//ensure the public directoy exists
if (!fs.existsSync("./public/")) {
  fs.mkdirSync("./public/");
}

let watch = false;
if (!isProduction) {
  watch = {
    onRebuild(error) {
      if (error)
        console.error("esbuild: Watch build failed:", error.getMessage());
      else console.log("esbuild: Watch build succeeded");
    },
  };
}

//esbuild options: https://esbuild.github.io/api/#build-api
const esbuildOptions = {
  entryPoints: [path.resolve(__dirname, "src", "ts", "main.ts")],
  outdir: path.resolve(__dirname, "public", "assets"),
  color: true,
  format: "esm",
  minify: isProduction,
  bundle: true,
  treeShaking: true,
  splitting: true,
  watch: watch,
  tsconfig: "tsconfig.json",
  sourcemap: !isProduction,
  plugins: [sveltePlugin(), sassPlugin({ type: "css" })],
  define: {
    "process.env.NODE_ENV": '"dev"',
    "process.env.DEBUG": "false",
  },
};

// run esbuild
esbuild.build(esbuildOptions).catch((err) => {
  console.error(err);
  process.exit(1);
});

// start web dev server
if (!isProduction) {
  const params = {
    port: 8080,
    root: "./public",
    open: true,
    wait: 0,
    logLevel: 2, // 0 = errors only, 1 = some, 2 = lots
  };
  liveServer.start(params);
}
