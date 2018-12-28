extends HTTPRequest

const domain = "smmdb.ddns.net"
const url = "https://" + domain + "/api/"


var call_back

signal on_http_data
signal on_donwloading
signal on_download_over

func _ready():
	connect("request_completed", self, "on_get_data")

func req_maps(start, num):
	var args = {
		prettify = 1,
		start = start,
		limit = num
	}
	
	var error = request_api("getcourses", args)
	if error != OK:
		# todo
		# show error
		print("request falied. code: " + str(error))

func req_download(id):	
	var t = Thread.new()
	t.start(self, "begin_download", id)

func begin_download(id):
	print("request download id: " + id)
	var http = HTTPClient.new()
	var err = http.connect_to_host(domain, 80, true)
	if err != OK:
		print("connect failed. code: " + str(err))
	
	while(http.get_status() == HTTPClient.STATUS_CONNECTING or http.get_status() == HTTPClient.STATUS_RESOLVING):
		http.poll()
		print("connecting")
		OS.delay_msec(100)
	
	var headers = [
		"User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36"
    ]
	var parmers = "/api/downloadcourse?type=zip&id=" + str(id)
	print(domain, parmers)
	err = http.request(HTTPClient.METHOD_GET, parmers , headers)
	if err != OK:
		print("download failed. code: " + str(err))
		return
	
	while (http.get_status() == HTTPClient.STATUS_REQUESTING):
		http.poll()
		OS.delay_msec(500)
	
	var data = PoolByteArray()
	if http.has_response():
		var header = http.get_response_headers_as_dictionary()
		while(http.get_status() == HTTPClient.STATUS_BODY):
			http.poll()
			var chunk = http.read_response_body_chunk()
			if chunk.size() == 0:
				OS.delay_msec(100)
			else:
				data += chunk
				call_deferred("on_downloading", data.size(), http.get_response_body_length())
	
	call_deferred("on_download_over", id, data)
	http.close()


func test_download(id):
	var args = {
		id = id
	}
	
	request_api("downloadcourse", args)

func on_downloading(cur_len, max_len):
	print("downloading " + str(cur_len) + "/" + str(max_len))
	emit_signal("on_donwloading", cur_len, max_len)


func on_download_over(id, data):
	print("download over")
	emit_signal("on_download_over")
	var file = File.new()
	file.open("res://download/" + str(id) + ".zip", File.WRITE_READ)
	file.store_buffer(data)
	file.close()


func request_api(api, args):
	var req_url = url +  api + "?"
	for arg in args.keys():
		req_url += arg + "=" + str(args[arg]) + "&"
	
	req_url[req_url.length() - 1] = ""
	print(req_url)
	return request(req_url)


func on_get_data(result, respond_code, headers, body):
	if respond_code != 200:
		print("respond code: " + str(respond_code))
		return
	
	var data = JSON.parse(body.get_string_from_utf8())
	emit_signal("on_http_data", data.result)
