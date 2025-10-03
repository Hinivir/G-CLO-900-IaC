FROM golang:1.23-alpine AS builder

WORKDIR /app
COPY . .
RUN go mod tidy
RUN go build -o api main.go

FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/api .

EXPOSE 18080
CMD ["./api"]