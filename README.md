# npc
node python container

部署
```shell
docker compose build
docker compose up -d
```

安装依赖
```python
pip3 install --break-system-packages -r requirements.txt
```
```node
npm install
```
注册sh命令
```shell
chmod +x /app/shell/task.sh
ln -sf /app/shell/task.sh /usr/local/bin/task
```
