# ---- Build stage ----
FROM node:20 AS builder

WORKDIR /app

# Install pnpm globally
RUN npm install -g pnpm

# Copy entire monorepo
COPY . .

# Install dependencies for the API package only
RUN pnpm install --filter api...

# Build the API
RUN pnpm --filter api... build


# ---- Run stage ----
FROM node:20 AS runner
WORKDIR /app

# Install pnpm globally
RUN npm install -g pnpm

# Copy only the built API from builder stage
COPY --from=builder /app/apps/api ./apps/api
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/pnpm-lock.yaml ./pnpm-lock.yaml
COPY --from=builder /app/package.json ./package.json

ENV PORT=3000

EXPOSE 3000

CMD ["pnpm", "--filter", "api...", "start"]
