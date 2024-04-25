# create database quanlynhansu;
use quanlynhansu;

create table department
(
    id   int primary key auto_increment,
    name varchar(100) not null unique check (length(name) >= 6)
);

create table levels
(
    id              int primary key auto_increment,
    name            varchar(100) not null unique,
    basicsalary     float        not null check (basicsalary >= 3500000),
    allowancesalary float default 500000
);



create table employee
(
    id           int primary key auto_increment,
    name         varchar(150) not null,
    email        varchar(150) not null unique check (email like '%_@__%.__%'),
    phone        varchar(50)  not null unique,
    address      varchar(255),
    gender       tinyint      not null check (gender in (0, 1, 2)),
    birthday     date         not null,
    levelid      int          not null,
    departmentid int          not null,
    foreign key (levelid) references levels (id),
    foreign key (departmentid) references department (id)
);

create table timesheets
(
    id             int primary key auto_increment,
    attendancedate date  not null default (now()),
    employeeid     int   not null,
    value          float not null default 1 check (value in (0, 0.5, 1)),
    foreign key (employeeid) references employee (id)
);

create table salary
(
    id          int primary key auto_increment,
    employeeid  int   not null,
    bonussalary float default 0,
    insurrance  float not null,
    foreign key (employeeid) references employee (id)
);

-- tạo trigger trước khi thêm hoặc cập nhật dữ liệu trong bảng salary
create trigger before_insert_update_salary_insurrance
    before insert
    on salary
    for each row
begin
    declare base_salary float;

    -- lấy giá trị của basicsalary và allowancesalary tương ứng với employeeid của bản ghi sắp được thêm hoặc cập nhật
    select l.basicsalary
    into base_salary
    from levels l
             join employee e on new.employeeid = e.id
    where e.levelid = l.id;

    -- gán giá trị cho cột insurrance bằng 10% của basicsalary
    set new.insurrance = 0.1 * base_salary;
end;

insert into department (name)
values ('vanhanh'),
       ('marketing'),
       ('daotao');


insert into levels (name, basicsalary, allowancesalary)
values ('junior', 4000000, 500000),
       ('senior', 6000000, 500000),
       ('manager', 9000000, 500000);

# insert into levels (name, basicsalary, allowancesalary)
# values ('pro', 400000000, 500000);


insert into employee (name, email, phone, address, gender, birthday, levelid, departmentid)
values ('john doe', 'john@example.com', '123456789', '123 main st', 1, '1990-01-01', 1, 1),
       ('jane smith', 'jane@example.com', '987654321', '456 elm st', 0, '1995-05-05', 2, 1);

-- thêm dữ liệu cho timesheets
insert into timesheets (attendancedate, employeeid, value)
values ('2024-04-01', 1, 1),
       ('2024-04-02', 1, 1),
       ('2024-04-03', 1, 0.5),
       ('2024-04-04', 1, 0.5),
       ('2024-04-05', 1, 0.5),
       ('2024-04-06', 1, 1),
       ('2024-04-07', 1, 1),
       ('2024-04-08', 1, 1),
       ('2024-04-09', 1, 1),
       ('2024-04-10', 1, 1),
       ('2024-04-11', 1, 1),
       ('2024-04-01', 2, 1),
       ('2024-04-02', 2, 0.5),
       ('2024-04-03', 2, 0.5),
       ('2024-04-04', 2, 0.5),
       ('2024-04-05', 2, 0.5),
       ('2024-04-06', 2, 1),
       ('2024-04-07', 2, 1),
       ('2024-04-08', 2, 1),
       ('2024-04-09', 2, 1),
       ('2024-04-10', 2, 1),
       ('2024-04-11', 2, 1);
insert into timesheets(attendancedate, employeeid, value)
values ('2024-04-12', 2, 1),
       ('2024-04-13', 2, 0.5),
       ('2024-04-14', 2, 0.5),
       ('2024-04-15', 2, 0.5),
       ('2024-04-16', 2, 0.5),
       ('2024-04-17', 2, 1),
       ('2024-04-18', 2, 1),
       ('2024-04-19', 2, 1),
       ('2024-04-20', 2, 1),
       ('2024-04-21', 2, 1),
       ('2024-04-23', 2, 1),
       ('2024-04-22', 2, 1);

insert into salary(employeeid, bonussalary)
values (1, 500000);
insert into salary(employeeid, bonussalary)
values (2, 200000);



#yc1

#1
select e.id,
       e.name,
       e.email,
       e.phone,
       e.address,
       e.gender,
       e.birthday,
       timestampdiff(year, e.birthday, curdate()) as age,
       d.name                                     as departmentname,
       l.name                                     as levelname
from employee e
         join department d on e.departmentid = d.id
         join levels l on e.levelid = l.id
order by name;

#2 lấy ra danh sách salary gồm: id, employeename, phone, email, basesalary, basicsalary, allowancesalary, bonussalary, insurrance, totalsalary

select s.id,
       e.name                                                             as employeename,
       e.phone,
       e.email,
       l.basicsalary                                                      as basesalary,
       l.allowancesalary                                                  as allowancesalary,
       s.bonussalary,
       s.insurrance,
       (l.basicsalary + l.allowancesalary + s.bonussalary - s.insurrance) as totalsalary
from salary s
         join employee e on s.employeeid = e.id
         join levels l on e.levelid = l.id;

#3 truy vấn danh sách department gồm: id, name, totalemployee

select d.id,
       d.name,
       count(e.id) as totalemployee
from department d
         left join employee e on d.id = e.departmentid
group by d.id, d.name;
#4 cập nhật cột bonussalary lên 10% cho tất cả các nhân viên có số ngày công >= 20 ngày trong tháng 10 năm 2020

update salary s
    join (select t.employeeid, sum(t.value) as totaldaysworked
          from timesheets t
          where t.attendancedate between '2020-10-01' and '2020-10-31'
          group by t.employeeid
          having sum(t.value) >= 20)
        as workedemployees on s.employeeid = workedemployees.employeeid
    join employee e on s.employeeid = e.id
    join levels l on e.levelid = l.id
set s.bonussalary = 0.1 * l.basicsalary
WHERE s.employeeid IN (SELECT employeeid FROM timesheets WHERE attendancedate BETWEEN '2020-10-01' AND '2020-10-31');
;

#5 truy vấn xóa phòng ban chưa có nhân viên nào

delete
from department
where id not in (select distinct departmentid from employee);



#yc2

#1 v_getemployeeinfo để lấy ra danh sách employee với cột gender hiển thị dưới dạng 'nữ' hoặc 'nam':

create view v_getemployeeinfo as
select e.id,
       e.name,
       e.email,
       e.phone,
       e.address,
       case e.gender
           when 0 then 'nữ'
           when 1 then 'nam'
           else 'khác'
           end as gender,
       e.birthday,
       d.name  as departmentname,
       l.name  as levelname
from employee e
         join department d on e.departmentid = d.id
         join levels l on e.levelid = l.id;


#2  v_getemployeesalarymax để hiển thị danh sách nhân viên có số ngày công trong một tháng bất kỳ lớn hơn 18:

create view v_getemployeesalarymax as
select e.id,
       e.name,
       e.email,
       e.phone,
       e.birthday,
       month(t.attendancedate) as month,
       year(t.attendancedate)  as year,
       sum(ifnull(t.value, 0)) as totalday
from employee e
         left join timesheets t on e.id = t.employeeid
group by e.id, e.name, e.email, e.phone, e.birthday, month(t.attendancedate), year(t.attendancedate)
having totalday > 18;


#yc3

#thủ tục addemployeetinfo để thêm mới nhân viên:

create procedure addemployeetinfo(
    in empname varchar(150),
    in empemail varchar(150),
    in empphone varchar(50),
    in empaddress varchar(255),
    in empgender tinyint,
    in empbirthday date,
    in emplevelid int,
    in empdepartmentid int
)
begin
    insert into employee (name, email, phone, address, gender, birthday, levelid, departmentid)
    values (empname, empemail, empphone, empaddress, empgender, empbirthday, emplevelid, empdepartmentid);
end;


#thủ tục getsalarybyemployeeid để hiển thị danh sách lương của một nhân viên theo id của họ:

create procedure getsalarybyemployeeid(
    in empid int
)
begin
    select s.id,
           e.name                                                             as employeename,
           e.phone,
           e.email,
           l.basicsalary,
           l.allowancesalary,
           s.bonussalary,
           s.insurrance,
           sum(ifnull(t.value, 0))                                            as totalday,
           (l.basicsalary + l.allowancesalary + s.bonussalary - s.insurrance) as totalsalary
    from salary s
             join employee e on s.employeeid = e.id
             join levels l on e.levelid = l.id
             left join timesheets t on e.id = t.employeeid
    where e.id = empid
    group by s.id;
end;

# thủ tục getemployeepaginate để lấy ra danh sách nhân viên có phân trang:

create procedure getemployeepaginate(
    in limitstart int,
    in limitoffset int
)
begin

    create procedure addemployeetinfo(
        in empname varchar(150),
        in empemail varchar(150),
        in empphone varchar(50),
        in empaddress varchar(255),
        in empgender tinyint,
        in empbirthday date,
        in emplevelid int,
        in empdepartmentid int
    )
    begin
        insert into employee (name, email, phone, address, gender, birthday, levelid, departmentid)
        values (empname, empemail, empphone, empaddress, empgender, empbirthday, emplevelid, empdepartmentid);
    end;
    select id,
           name,
           email,
           phone,
           address,
           case gender
               when 0 then 'nữ'
               when 1 then 'nam'
               else 'khác'
               end as gender,
           birthday
    from employee
    limit limitstart, limitoffset;
end;


#yc4

# trigger tr_check_insurrance_value để kiểm tra giá trị cột insurrance trong bảng salary:

create trigger tr_check_insurrance_value
    before insert
    on salary
    for each row
begin
    declare base_salary float;
    declare required_insurrance float;

    -- lấy giá trị của basicsalary tương ứng với levelid của nhân viên
    select basicsalary into base_salary from levels where id = new.employeeid;

    -- tính giá trị bắt buộc của insurrance
    set required_insurrance = 0.1 * base_salary;

    -- kiểm tra nếu insurrance không bằng 10% của basicsalary thì không cho phép thêm mới hoặc chỉnh sửa
    if new.insurrance != required_insurrance then
        signal sqlstate '45000'
            set message_text = 'giá trị của insurrance phải bằng 10% của basicsalary';
    end if;
end;


# trigger tr_check_basic_salary để kiểm tra giá trị cột basicsalary trong bảng levels:

create trigger tr_check_basic_salary
    before insert
    on levels
    for each row
begin
    -- kiểm tra nếu giá trị cột basicsalary > 10000000 thì tự động đưa về giá trị 10000000
    if new.basicsalary > 10000000 then
        set new.basicsalary = 10000000;
        signal sqlstate '45000'
            set message_text = 'lương cơ bản không vượt quá 10 triệu';
    end if;
end;

