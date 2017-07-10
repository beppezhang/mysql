1：一张表插入数据到另外一张表中：有相应的数据则更新，没有数据则新增    使用条件表中必须要有唯一键
INSERT INTO ad_pool (   
	id,
	ad,
	industry_tag1,
	industry_tag2
) SELECT
	UUID(),
	ad,
	industry_tag1,
	industry_tag2
FROM
	ad_pool_test test
on DUPLICATE KEY UPDATE ad_pool.industry_tag1=test.industry_tag1,ad_pool.industry_tag2=test.industry_tag2

2：多表关联查询：内连接 左连接 一表多次使用  日期格式(查找前一天)
SELECT
	c.*, s.ad,
	cus.mobile,
  properties1.value as '自定义属性1',
   properties2.value as '自定义属性2',
  l.title,
  properties3.value as '保留区自定义属性1',
--  properties4.value as '保留区自定义属性2',
  secret.custom_properties3 as '保留区自定义属性3'
FROM
	call_record c
LEFT JOIN secret_pool s ON c.secret_id = s.secret_id
LEFT JOIN keep_secret secret on c.secret_id=secret.secret_id
INNER JOIN language_trick l on c.language_trick_id=l.id
LEFT JOIN custom_properties properties1 on c.custom_properties_id1=properties1.id
LEFT JOIN custom_properties properties2 on c.custom_properties_id2=properties2.id
LEFT JOIN custom_properties properties3 on secret.custom_properties_id1=properties3.id
-- LEFT JOIN custom_properties properties4 on secret.custom_properties_id2=properties4.id
LEFT JOIN customer cus ON cus.secret_id = s.secret_id
where 	DATE_FORMAT(c.create_time,'%Y%m%d')=(DATE_FORMAT(NOW(),'%Y%m%d')-1)
备注：内连接：查询的结果为：满足 on 后面的连接条件；左连接：查询结果：LEFT 左边字段全部显示出来，不满足 on 后面的连接条件的则显示为空，
这里 custom_properties 做了多次的引用，把它当做多个不同表来用，DATE_FORMAT 语法是自定义时间日期格式；这里 '%Y%m%d' 表示 年月日 如：2017-6-29；

3：批量更新：根据两表之间的连接关系来批量更新其中一张表的数据到另外一张表上；以下sql：将 call_record 表中的call_time 更新到 secret_pool 表中的call_time
last_dial_time字段中，连接条件是 s.secret_id = c.secret_id
UPDATE secret_pool s,
 call_record c
SET s.last_dial_time = c.call_time ON s.secret_id = c.secret_id

4：树状结构表 单表联表查询：应用场景 省市区 查询  以下sql：查出 省 下所有的市，市下所有的区
SELECT
	r1.*,r2.*
FROM
	`region` r1
INNER JOIN region r2 ON r1.`code` = r2.parent_code
WHERE
	r1. LEVEL = 1
OR r1. LEVEL = 2
