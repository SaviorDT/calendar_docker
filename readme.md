這個環境主要用於開發用途，並且為了我的需求有稍微特化過，有一些使用前需要注意的地方

1. 首先注意 compose file 內的 network，我為了在一台 host 上面 run 許多 services，禁止所有容器對外的 port，包括 nginx，你如果需要可以把
   ```
   networks:
   # A router to manage all containers So you can run many services on port 80 in a single host.
   # If you don't need this, you can remove it and expose nginx on port 80.
   router_network:
      external: true
   ```
   改成
   ```
   networks:
   router_network:
      driver: bridge
   ```
   並且在 nginx 內設置 ports，應該會能動。
   ```
   nginx:
      image: nginx:latest
      volumes:
         - ./nginx/default.conf:/etc/nginx/conf.d/default.conf
      networks:
         - internal_network
         - router_network
      ports:
         - "80:80"
   ```

1. nginx/default.conf 內，可以填入網址，他的功能是讓所有流量從可以從同一個 dst ip, port 進入，但是根據網址不同，訪問不同服務，主要是修改 server_name，例如第一個 server 的意思是，如果從網址 `xn--3kqq40dtwx.xn--kss.xn--kpry57d` 進來，他會將請求傳給 frontend

1. 使用前請先到 ./secrets 內執行 generate_secrets.bat 或 generate_secrets.sh，根據你的作業系統決定，它會自動生成一些包含密碼、密鑰的檔案，當然如果你需要你可以自行修改，他不會覆蓋任何已有的檔案。另外， .bat 檔案並沒有經過測試，但肉眼看起來應該要能動。

1. 使用前請先到 `./ssh_keys` 新增檔案，例如 `./ssh_keys/id_rsa`，可使用 `ssh-keygen` 生成，需要設定這個 key 可以用於登入或是用於存取專案。

1. 執行 docker compose up，並且等待他自動將專案同步，第一次執行時，可能有些容器會 crash，不用擔心，等待 update 這個容器執行完畢後再開啟其他容器即可。

1. 因為 pip 會在全域安裝，而不是像 node 或 php 安裝在資料夾內，所以需要自己去容器內執行 `pip install -r requirements.txt`

1. 記得去 frontend 的容器內的 `src/main.js` 裡面把 `axios.defaults.baseURL` 改成你自己的後端網址。