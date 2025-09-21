# UI / Stimulus

## Controllers
- `party_type_controller.js` — toggles person/org sections and sets `_destroy`.
- `dependent_select_controller.js` — loads regions for selected country.
- `nested_form_controller.js` — adds/removes address rows; sets default country "US".
- `reveal_controller.js` — fetches decrypted values on click.
- `toggle_input_controller.js` — disables autofill prompts until focus for sensitive fields.

### party_type_controller.js
Targets: `select`, `personSection`, `orgSection`, `personDestroy`, `orgDestroy`. On `connect` and `change`, show/hide sections and set `_destroy` flags.

### dependent_select_controller.js
- `urlValue` points to `ref/regions#index`.
- Targets: `country`, `region`.
- On connect/refresh: fetch JSON `?country=US&_=${Date.now()}`, populate region options, set `data-current` value.

### nested_form_controller.js
- `add()` clones `<template>` row and ensures `country_code` defaults to `"US"` then dispatches change to load regions.

### Wiring
- `app/javascript/application.js`: `import "controllers"`
- `app/javascript/controllers/index.js`: `eagerLoadControllersFrom("controllers", application)`

## Tailwind + daisyUI
- Tailwind v4 via CLI (`npx tailwindcss -i app/assets/tailwind/application.css -o app/assets/builds/application.css --watch`)
- daisyUI is added in Tailwind config (v4 plugin format).