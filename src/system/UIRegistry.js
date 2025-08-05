// src/system/UI_registry.js
export class UIRegistry {
  constructor() {
    this.formSchemas = new Map();
  }

  /**
   * @param {string} typeName   e.g. "Panel", "Stiffener"
   * @param {object} schema     JSON/schema describing fields, labels, types
   */
  registerFormSchema(typeName, schema) {
    if (this.formSchemas.has(typeName)) {
      console.warn(`Overwriting form schema for ${typeName}`);
    }
    this.formSchemas.set(typeName, schema);
  }

  /**
   * Look up the schema for a given type
   * @param {string} typeName
   * @returns {object|undefined}
   */
  getFormSchema(typeName) {
    return this.formSchemas.get(typeName);
  }
}

// singleton instance
export const uiRegistry = new UIRegistry();
