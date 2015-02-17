package assets

import (
	"regexp"
	"bytes"
	"log"
	"net/http"

	"github.com/zenazn/goji"
	"github.com/zenazn/goji/web"
)

func main() {

}

func Handler(c web.C, w http.ResponseWriter, r *http.Request) {

	url := c.URLParams["asset"]

	if url == "" {
		url = "index.html"
	}

	log.Println("fetch: ", url)

	data, err := Asset(url)

	if err != nil {
		http.NotFound(w, r)
		return
	}

	info, err := AssetInfo(url)

	if err != nil {
		http.Error(w, "An error has occurred with asset's info", 500)
		return
	}

	http.ServeContent(w, r, url, info.ModTime(), bytes.NewReader(data))
}

func Bind() {
	route := regexp.MustCompile("^/(?P<asset>.*)$")
    goji.Get(route, Handler)
}