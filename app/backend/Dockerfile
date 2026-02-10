# Etapa de compilación
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY main.go .
RUN go build -o backend main.go

# Etapa final (imagen ligera)
FROM alpine:latest
WORKDIR /root/
COPY --from=builder /app/backend .
EXPOSE 8080
CMD ["./backend"]
