/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./app/views/**/*.{html.erb, html, js}",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./public/**/*.html",
  ],
  theme: {
    extend: {
      colors: {
        // your custom colors
      },
      // etc
    }
  },
  plugins: [
    require("daisyui"),
    // other plugins
  ],
  daisyui: {
    themes: [
      "light",
      "dark",
      // etc
    ],
  },
};
