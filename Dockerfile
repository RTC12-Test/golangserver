FROM golang as build

WORKDIR /app
COPY . .
RUN go mod tidy
RUN CGO_ENABLED=0 GOOS=linux go build -o main main.go

FROM scratch
WORKDIR /app
COPY --from=build /app/main .
EXPOSE 8080
CMD ["./main"]
