package main
import (
  "fmt"
  "github.com/gin-gonic/gin"
)

func main() {
	router := gin.Default()
	router.Static("/", "../client/dist")


	// Listen and serve on 0.0.0.0:8080
  fmt.Println("Listening on http://localhost:8080")
	router.Run(":8080")
}

