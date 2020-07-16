import LinPy, string, random, datetime

count_of_rows = [10, 100, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000, 20000, 30000, 40000, 50000, 60000, 70000, 80000, 90000, 100000, 200000, 300000, 400000, 500000, 600000, 700000, 800000, 900000, 1000000]

# 89,482 байт - one entry, 1419 corteges
# 19,422 байт - one entry, 3796 corteges

def randomword(length):
   letters = string.ascii_lowercase
   return ''.join(random.choice(letters) for i in range(length))

def init_data(list_of_values, count_of_records):
    for i in range(count_of_records):
        local_list = []
        id = random.randint(1, 100000)
        str = randomword(20)
        local_time = datetime.datetime.today()
        str_local_time = local_time.strftime("%H:%M:%S %Y:%m:%d")
        
        local_list.append(i+1)
        local_list.append(str_local_time)
        local_list.append(id)
        local_list.append(str)
        local_list.append(str)
        
        list_of_values.append(local_list)

def drop_and_create_table(cursor):
    cursor.execute("drop index IDX_LogTable_LogId on LogTable;")
    cursor.execute("drop table LogTable;")
    cursor.execute("create or replace table LogTable(LogId int, Timestmp CHAR(20), SubjectId int, ObjectName CHAR(32), Action CHAR(32));")
    cursor.execute("create or replace index IDX_LogTable_LogId on LogTable(LogId);")

def select_size_of_LogTable(cursor):
    cursor.execute("select cast ($$$s34 as char(18)) as \"UserName\", cast ($$$s13 as char(18)) as \"TableName\", linter_file_info($$$s11,1,1,'size') as \"DataFileSize\", linter_file_info($$$s11,0,1,'size') as \"IndexFileSize\", linter_file_info($$$s11,0,1,'full_page_count') as \"IndexFullCount\", linter_file_info($$$s11,0,1,'free_page_count') as \"IndexFreeCount\", case when getbyte($$$s14,102) > 0 then linter_file_info($$$s11,2,1,'full_page_count') else NULL end as \"BlobFullCount\", case when getbyte($$$s14,102) > 0 then linter_file_info($$$s11,2,1,'free_page_count') else NULL end as \"BlobFreeCount\" from LINTER_SYSTEM_USER.$$$sysrl, LINTER_SYSTEM_USER.$$$usr where $$$s31 = $$$s12 and $$$s11 > 0 and $$$s32 = 0 and getbyte($$$s14,6) = 0 and $$$s13 = 'LOGTABLE';")
    return(cursor.fetchall())
    
def test_size_of_databases_and_indexes():
    connection = LinPy.connect('SYSTEM', 'MANAGER')
    cursor = connection.cursor()
    
    file_results = open('results.txt', 'w')

    drop_and_create_table(cursor)
    result_size = select_size_of_LogTable(cursor)
    
    file_results.write("0: %s\n" % str(result_size[0]))
    
    for local_count in count_of_rows:    
        list_of_values = []
        drop_and_create_table(cursor)
        init_data(list_of_values, local_count)
        
        for i in range(local_count):
            local_list = list_of_values[i]
            cursor.execute("insert into LogTable (LogId, Timestmp, SubjectId, ObjectName, Action) values (?, ?, ?, ?, ?)", (local_list[0], local_list[1], local_list[2], local_list[3], local_list[4]))
        
        result_size = select_size_of_LogTable(cursor)

        file_results.write(str(local_count) + ": ")
        file_results.write("%s\n" % str(result_size[0]))

        print(str(local_count) + ": " + str(select_size_of_LogTable(cursor)))
        
    file_results.close()

def main():
   test_size_of_databases_and_indexes()

if __name__ == '__main__':
    main()