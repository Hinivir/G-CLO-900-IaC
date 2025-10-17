# Étape 1 : Build
FROM golang:1.23 AS builder

WORKDIR /app
COPY . .

RUN go mod init api || true
RUN go mod tidy
RUN go build -o main .

# Étape 2 : Runtime
FROM gcr.io/distroless/base-debian12

WORKDIR /app
COPY --from=builder /app/main .

EXPOSE 8000
CMD ["./main"]