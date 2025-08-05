// src/bootstrap.js
import { uiRegistry } from "./system/UIRegistry";

// create a context for every form.js in plugins/**/
const pluginForms = require.context(
  "./plugins",    // directory
  true,           // recursive
  /form\.js$/     // match files named form.js
);

pluginForms.keys().forEach((modulePath) => {
  const { registerForm } = pluginForms(modulePath);
  if (typeof registerForm === "function") {
    registerForm(uiRegistry);
    console.log(`[UI] Registered form from ${modulePath}`);
  }
});
