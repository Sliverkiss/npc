# npc
node python container
<p>自用脚本任务运行框架，用于统一管理和执行各种脚本任务</p>

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
