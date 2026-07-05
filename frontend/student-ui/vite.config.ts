import { defineConfig, loadEnv } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '')
  const authTarget = env.VITE_AUTH_URL || 'http://localhost:8001'
  const gatewayTarget = env.VITE_GATEWAY_URL || 'http://localhost:8000'

  return {
    plugins: [react()],
    build: {
      sourcemap: false,
      minify: 'esbuild',
    },
    server: {
      port: 5173,
      proxy: {
        '/auth': {
          target: authTarget,
          changeOrigin: true,
        },
        '/api': {
          target: gatewayTarget,
          changeOrigin: true,
        },
      },
    },
  }
})
