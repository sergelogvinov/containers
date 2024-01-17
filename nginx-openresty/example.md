# nginx-device-detection vhost example

```shell
51D_filePath /opt/51degrees.trie;

server {
    listen 8080 default_server;

    location / {
        51D_match_single x-device HardwareName,BrowserName,PlatformName;

        51D_match_all x-mobile IsMobile;
        51D_match_all x-tablet IsTablet;
        51D_match_all x-smartphone IsSmartPhone;

        add_header x-device $http_x_device;
        add_header x-mobile $http_x_mobile;
        add_header x-tablet $http_x_tablet;
        add_header x-smartphone $http_x_smartphone;

        default_type 'text/plain';

        content_by_lua_block {
            ngx.say('<pre>' .. ngx.req.raw_header() .. '</pre>')
        }
    }
}
```
