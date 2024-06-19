package main

import (
	"errors"
	"fmt"
	"net/http"
	"path/filepath"

	"github.com/gin-gonic/gin"
)

func main() {
	router := gin.Default()

	basepath := "/library" // Volume inside docker container

	// Set a lower memory limit for multipart forms (default is 32 MiB). This does not affect file size, it only limits the server memory used.
	router.MaxMultipartMemory = 8 << 20 // 8 MiB
	router.Static("/", "./public")
	router.POST("/upload", func(c *gin.Context) {
		folder := c.PostForm("folder")

		// Multipart form
		form, err := c.MultipartForm()
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		files := form.File["files"]
		for _, file := range files {
			filename := filepath.Base(file.Filename)
			filePath := filepath.Join(basepath, folder, filename)

			cleanPath, err := verifyPath(filePath, basepath)
			if err != nil {
				c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
				return
			}

			if err := c.SaveUploadedFile(file, cleanPath); err != nil {
				c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
				return
			}
		}

		c.JSON(http.StatusOK, gin.H{
			"message": fmt.Sprintf("Uploaded %d file(s) successfully into folder %s.", len(files), folder),
		})
	})
	router.Run(":8080")
}

// https://www.stackhawk.com/blog/golang-path-traversal-guide-examples-and-prevention/
// prevent path traversal attacks
func verifyPath(path, basepath string) (string, error) {

	c := filepath.Clean(path)

	err := inTrustedRoot(c, basepath)
	if err != nil {
		fmt.Println("Error " + err.Error())
		return c, errors.New("unsafe or invalid path specified")
	} else {
		return c, nil
	}
}
func inTrustedRoot(path string, trustedRoot string) error {
	for path != "/" {
		path = filepath.Dir(path)
		if path == trustedRoot {
			return nil
		}
	}
	return errors.New("path is outside of trusted root")
}
