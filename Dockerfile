FROM golang:alpine as stage1

WORKDIR /app
COPY backend/go.mod .
RUN go mod download

COPY backend/main.go .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

FROM node:14 as stage2
WORKDIR /app
COPY /frontend/package.json .
RUN yarn

COPY /frontend/public/ ./public/
COPY /frontend/src/ ./src/
RUN yarn build

FROM alpine as stage3
WORKDIR /app
COPY --from=stage1 /app/main .
COPY --from=stage2 /app/build/  ./build/
CMD ["./main"]