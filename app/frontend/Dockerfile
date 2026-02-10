# Build Stage
FROM node:18-alpine as build
WORKDIR /app
# Simulamos un proyecto simple sin mil dependencias
RUN npx create-vite@latest . --template react-ts --yes
RUN npm install
# Sobreescribimos el App.tsx con nuestro código
COPY App.tsx ./src/App.tsx
RUN npm run build

# Serve Stage
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
