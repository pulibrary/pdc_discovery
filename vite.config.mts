import path from 'node:path';
import { defineConfig } from 'vite';
import RubyPlugin from 'vite-plugin-ruby';

export default defineConfig({
  plugins: [RubyPlugin()],
  resolve: {
    alias: {
      '@images': path.resolve(__dirname, 'app/assets/images'),
    },
  },
  server: {
    fs: {
      allow: [path.resolve(__dirname, 'app/assets/images')],
    },
  },
});
