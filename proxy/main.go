package main

import (
	"encoding/base64"
	"fmt"
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"runtime"
	"strings"
	"strconv"
)

//创建一个直接的反向代理，直接用新的url替换原有request中的的url
func NewDirectReverseProxy(target *url.URL) *httputil.ReverseProxy {
	/*
	targetQuery := target.RawQuery
	director := func(req *http.Request) {
		req.URL.Scheme = target.Scheme
		req.URL.Host = target.Host
		req.URL.Path = singleJoiningSlash(target.Path, req.URL.Path)
		if targetQuery == "" || req.URL.RawQuery == "" {
			req.URL.RawQuery = targetQuery + req.URL.RawQuery
		} else {
			req.URL.RawQuery = targetQuery + "&" + req.URL.RawQuery
		}
	}
	*/
	director := func(req *http.Request) {
		req.URL = target
		//req.URL.Scheme = target.Scheme
		//req.URL.Host = target.Host
		////req.URL.Path = "/"
		//println(target.Scheme, target.Host, target.Path)
		fmt.Printf("url_path=%s, url_query=%s\n", req.URL.Path, req.URL.RawQuery)
		req.Header.Add("Refer", "http://vod.lixian.xunlei.com/media/vodPlayer_2.8.swf?v=2.8.991.01");
	}
	return &httputil.ReverseProxy{Director: director}
}

// 反向代理
func reverseProxy(url *url.URL, respWriter http.ResponseWriter, req *http.Request) {
	reverseProxy := NewDirectReverseProxy(url)
	reverseProxy.ServeHTTP(respWriter, req)
}


func get_media_url(uri *url.URL) (url string) {
	values := uri.Query()
	euri := values.Get("id")

	data, err := base64.StdEncoding.DecodeString(euri)
	if err != nil {
		fmt.Println("error:", err)
		return ""
	}

	url = string(data)
	url = strings.TrimPrefix(url, "[XLLX]")
	url = strings.TrimPrefix(url, "[XLLX]")
	url = strings.TrimSuffix(url, "[XLLX]")
	println("media url=%s\n", url)
	return url
}

func genTargetUrl(req *http.Request) (url *url.URL, range_start int, range_end int) {
	var start, end string
	orig_url := get_media_url(req.URL)

	url, err := url.Parse(orig_url)
	if err != nil {
		println("xxx")
	}

	queries := url.Query()
	start = queries.Get("start")
	end = queries.Get("end")

	range_bytes := req.Header.Get("Range")
	if len(range_bytes) > 0 && strings.HasPrefix(range_bytes, "bytes=") {
		range_bytes = strings.TrimPrefix(range_bytes, "bytes=")
		if strings.HasSuffix(range_bytes, "-") {
			start = strings.TrimSuffix(range_bytes, "-")
		} else {
			pos := strings.Index(range_bytes, "-")
			start = range_bytes[:pos]
			end = range_bytes[pos+1:]
		}
	}

	queries.Set("start", start)
	queries.Set("end", end)
	vals := queries.Encode()
	url.RawQuery = vals


	range_start, _ = strconv.Atoi(start)
	range_end, _ = strconv.Atoi(end)

	fmt.Printf("range start=%s, end=%s\n", start, end)
	fmt.Printf("vals, %v\n", vals)

	return
}

func handerAll(rw http.ResponseWriter, req *http.Request) {
	var length int
	v, _ := httputil.DumpRequest(req, false)
	println("%v", string(v))

	out_url, start, end := genTargetUrl(req)

	if start > 0 {
		//rw.WriteHeader(http.StatusPartialContent)
		length = end -start
		content_range := "bytes " + strconv.Itoa(start) + "-" + strconv.Itoa(end-1) + "/" + strconv.Itoa(end)
		content_length := strconv.Itoa(length)
		rw.Header().Set("Content-Range", content_range)
		rw.Header().Set("Content-Length", content_length)
	}

	// 获得原始的url
	//originUrlStr := url.String()
	//var finalUrlStr string

	// 没有匹配的url转换映射，则直接反向代理；如果匹配上了则根据isReverseProxy来判读是否是反向代理
	//finalUrlStr = originUrlStr
	//finalUrlStr = "http://www.zhcn.cc"
	//url = "http://www.baidu.com"
	//targetUrl, err := url.Parse(finalUrlStr)
	//if err != nil {
	//	println("xxx")
	//}



	//respWriter.Header().Set("goproxy", finalUrlStr) // 在代理请求前把最终的url设置到相应头中
	//rw.Header().Set("goproxy", finalUrlStr) // 在代理请求前把最终的url设置到相应头中
	//R 01-7-12 19:19:40 Content-Range: bytes 5275648-15143085/15143086 
	//R 01-7-12 19:19:40 Content-Length: 9867438 
	//StatusPartialContent

	reverseProxy(out_url, rw, req)
}

func main() {
	var err error
	//u, err := url.Parse("http://www.cnn.com")
	//if err != nil {
	//	log.Fatal(err)
	//}

	//reverse_proxy := httputil.NewSingleHostReverseProxy(u)
	//http.Handle("/", reverse_proxy)
	http.HandleFunc("/vod", handerAll)
	runtime.GOMAXPROCS(runtime.NumCPU())

	log.Println("Server started")
	if err = http.ListenAndServe(":8080", nil); err != nil {
		log.Fatal(err)
	}
}
