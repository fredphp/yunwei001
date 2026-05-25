-- 等待 MySQL 完全启动后执行
-- 此文件由 docker-entrypoint-initdb.d 自动执行

-- 确保字符集（utf8mb4 才是真正的 UTF-8，MySQL 的 utf8 只有3字节，无法存储 emoji 和部分中文）
ALTER DATABASE fantan_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
