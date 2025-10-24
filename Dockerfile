FROM golang:1.24-alpine AS builder

RUN apk add --no-cache git bash

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -o bin/notifier ./cmd/notifier
RUN go build -o bin/worker ./cmd/worker

FROM alpine:3.18

RUN apk add -no-cache ca-certificates

WORKDIR /app

COPY --from=builder /app/bin /app/bin
COPY --from=builder /app/configs /app/configs

EXPOSE 8080

CMD [ "/app/bin/notifier" ]