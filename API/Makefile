APP_NAME = api
PORT = 18080

build:
	go mod tidy
	go build -o $(APP_NAME) main.go

run: build
	./$(APP_NAME)

docker-build:
	docker build -t my-api .

docker-run:
	docker run -p $(PORT):18080 my-api