FROM gcc:12

WORKDIR /app
COPY . .

RUN make

EXPOSE 18080
CMD ["./build/rest-server", "18080"]