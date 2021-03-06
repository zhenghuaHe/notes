# mysql数据库使用的注意事项
* 建表的角度上
1. 合理安排表关系
2. 尽量把固定长度的字段放在前面
3. 尽量使用char代替varchar
4. 分表：水平分和垂直分

* 在使用sql语句的时候
1. 尽量用where来约束范围到一个比较小范围的程度，比如分页
2. 尽量使用连表查询，而不是使用子查询
3. 删除数据或者修改数据的时候尽量使用主键作为条件
4. 合理创建和引用索引

* 正确使用索引
1. 查询的条件字段不是索引字段，对哪一个字段创建了索引就对哪一个字段做条件查询
2. 在创建索引的时候应该对区分度比较大的列进行创建1/10以下的重复率比较适合创建索引
3. 范围
   范围越大越慢
   范围越小越快
   ！= 慢
   like 'a%' 快
   like '%a' 慢
4. 件列参与计算/使用函数
5. and 和 or
   多个条件的组合，如果使用and连接，其中一列含有索引，都可以加快查找速度
   如果使用or连接，必须所有的列都含有索引，才能加快查询速度

6. 联合索引（最左前缀原则）必须带这最左边的列作为条件，从出现范围开始整条索引失效
