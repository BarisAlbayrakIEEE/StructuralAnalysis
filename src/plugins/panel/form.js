// src/plugins/panel/form.js
export function registerForm(uiRegistry) {
  uiRegistry.registerFormSchema("Panel", {
    title: "Panel Properties",
    fields: [
      { name: "name",       label: "Name",       type: "text"   },
      { name: "width",      label: "Width",      type: "number" },
      { name: "height",     label: "Height",     type: "number" },
      { name: "thickness",  label: "Thickness",  type: "number" }
    ]
  });
}
