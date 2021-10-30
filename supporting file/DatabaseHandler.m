 //
//  DatabaseHandler.m
//
//
//  Created by development6 on 30/06/17.
//  Copyright (c) 2014 . All rights reserved.

#import "DatabaseHandler.h"


@implementation DatabaseHandler
{
    NSString *databasePath;
}


-(void)openDb{
    //Using NSFileManager we can perform many file system operations.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    // Set the documents directory path to the documentsDirectory property.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    databasePath =   [documentsDir stringByAppendingPathComponent:@"iPray.sqlite"];
  //  NSLog(@"My data base path%@",databasePath);
    
    
//    NSString *documentsDir =
//    NSURL * url = [fileManager containerURLForSecurityApplicationGroupIdentifier:@"group.oFaceKeyboardExtensionSharingDefaults1"];
    
    //get DataBase Path
  //  databasePath = [[url path] stringByAppendingPathComponent:@"iPray.sqlite"];
   
    
    //check if database file is not existing at path then copy it to that path
    BOOL success = [fileManager fileExistsAtPath:databasePath];
    
    if(!success) {
        
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"iPray.sqlite"];
        success = [fileManager copyItemAtPath:defaultDBPath toPath:databasePath error:&error];
        
        if (!success)
            NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
    
}

#pragma mark- Auto Insert Update
-(void)autoInsertUpdate:(NSString*)tableName Data:(NSDictionary*)data Where:(NSString*)whereClause{
    
    
    BOOL isExist = [self isRecordExist:tableName where:whereClause];
    
    if (isExist) {
        
        [self update:tableName :data :whereClause];
    }
    else{
        [self insert:tableName :data];
    }
    
}
-(BOOL)isRecordExist:(NSString *)tableName where :(NSString *)where {
    int x=0;
    
    [ self openDb];
    sqlite3_close(db);
    if(sqlite3_open([databasePath UTF8String], &db)==SQLITE_OK)
    {
        NSString *query =[NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE %@",tableName,where];
       // NSLog(@"%@", query);
        //@"SELECT country_name FROM sg_country";
        
        
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil)
            == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                
                x=sqlite3_column_int(statement, 0);
                
                
            }
            sqlite3_finalize(statement);
            sqlite3_close(db);
        }
        else
        {
            NSLog(@"can't perform isExist");
        }
    }
    if (x==0) {
        return NO;
    }
    else{
        return YES;
    }
    
}
-(BOOL) update:(NSString*)table_ID : (NSDictionary *) data :(NSString*) whereClause
{
    NSLock *_lock = [NSLock new];
    [_lock lock];
    
    BOOL success = NO;
    sqlite3_close(db);
    if (sqlite3_open([databasePath UTF8String], &db) == SQLITE_OK) {
        sqlite3_stmt *updateStmt;
        NSString *key = nil;
        for (NSString *k in [data allKeys]) {
            key = (key == nil)?[NSString stringWithFormat:@"%@ = %@",k,[NSString stringWithFormat:@"'%@'",[data valueForKey:k]]] : [key stringByAppendingFormat:@", %@ = %@",k,[NSString stringWithFormat:@"'%@'",[data valueForKey:k]]];
        }
        NSString *query = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@", table_ID, key, whereClause];
        NSLog(@"Update Query === %@",query);
        if(sqlite3_prepare_v2(db, [query UTF8String], -1, &updateStmt, NULL) == SQLITE_OK){
            
            [self createValues:updateStmt :data];
            
            if(SQLITE_DONE == sqlite3_step(updateStmt)){
                NSLog(@"PRO_DB_UPDATE=====> Record Updated Successfully");
                success = YES;
            }
            else{
                NSLog(@"PRO_DB_UPDATE=====> Error while adding record. '%s'", sqlite3_errmsg(db));
            }
        }
        else {
            NSLog(@"PRO_DB_UPDATE=====> Error while preapring statement. '%s'", sqlite3_errmsg(db));
        }
        
        sqlite3_finalize(updateStmt);
        sqlite3_close(db);
    }
    else {
        NSLog(@"PRO_DB_INSERT=====> Error while opening database '%s'", sqlite3_errmsg(db));
    }
    [_lock unlock];
    return success;
    
}
 -(int) insert:(NSString*)table_ID : (NSDictionary *) data{
    
  //  NSLog(@"table_id %@",table_ID);
  //  NSLog(@"dataDictionary %@",[data description]);
    NSLock *_lock = [NSLock new];
    
    [_lock lock];
    
    int rowId = -1;
    sqlite3_close(db);
    if (sqlite3_open([databasePath UTF8String], &db) == SQLITE_OK) {
        
        sqlite3_stmt *addStmt;
        
        NSString *key = nil;
        NSString *value = nil;
        
        for (NSString *k in [data allKeys]) {
            
         //   NSLog(@"keyValue %@",k);
         //   NSLog(@"Value %@",[data valueForKey:k]);
            
            key = (key == nil)?[NSString stringWithString:k] : [key stringByAppendingFormat:@",%@",k];
            value =(value == nil)?[NSString stringWithFormat:@"'%@'",[data valueForKey:k]]:[value stringByAppendingString:[NSString stringWithFormat:@",'%@'",[data valueForKey:k]]];
        }
        
        NSString *query = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES(%@)", table_ID, key, value];
        
     //   NSLog(@"Insert query = %@",query);
        if(sqlite3_prepare_v2(db, [query UTF8String], -1, &addStmt, NULL) == SQLITE_OK){
            
            [self createValues:addStmt :data];
            
            if(SQLITE_DONE == sqlite3_step(addStmt)){
               // NSLog(@"PRO_DB_INSERT=====> Record Inserted Successfully");
                rowId = (int)sqlite3_last_insert_rowid(db);
              //  NSLog(@"RowId While Inserting %d",rowId);
            }
            else{
                NSLog(@"PRO_DB_INSERT =====> Error while adding record. '%s'", sqlite3_errmsg(db));
            }
        }
        else {
            NSLog(@"PRO_DB_INSERT =====> Error while preapring statement. '%s'", sqlite3_errmsg(db));
        }
        
        
        sqlite3_finalize(addStmt);
        sqlite3_close(db);
    }
    else {
        NSLog(@"PRO_DB_INSERT =====> Error while opening database '%s'", sqlite3_errmsg(db));
    }
    
    
    [_lock unlock];
    
    return rowId;
    
}
-(void) createValues:(sqlite3_stmt *)stmt :(NSDictionary *)dict{
    
    //  NSLog(@"dict %@",[dict description]);
    NSLock *_lock = [NSLock new];
    [_lock lock];
    
    int i=0;
    for (NSString *key in [dict allKeys]) {
        sqlite3_bind_text(stmt, i+1, [[NSString stringWithFormat:@"%@",[dict objectForKey:key]] UTF8String], -1, SQLITE_TRANSIENT);
        i++;
    }
    
    [_lock unlock];
    //sqlite3_bind_text(addStmt, 2, [[data objectForKey:@"location"] UTF8String],-1, SQLITE_TRANSIENT);
}
#pragma mark -Get Singal Data
-(NSMutableString *)getSigalData:(NSString*)tableID data:(NSString*)data where:(NSString *)whereClause
{
    NSLock *_lock = [NSLock new] ;
    [_lock lock];
    
    NSMutableString *stringToReturn;
   // NSMutableArray *arrayToReturn=[[NSMutableArray alloc]init] ;
    NSString *query;
    
    if (whereClause == nil) {
        query = [NSString stringWithFormat:@"SELECT %@ FROM %@ ",data,tableID];
    }
    else {
        query = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@",data,tableID, whereClause];
    }
    
    NSLog(@"query =========> %@",query);
    [ self openDb];
    sqlite3_close(db);
    if((sqlite3_open([databasePath UTF8String], &db))==SQLITE_OK)
    {
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, NULL)==SQLITE_OK)
        {
            while(sqlite3_step(statement)==SQLITE_ROW)
            {
                NSMutableDictionary *tempDisc=[[NSMutableDictionary alloc] init];
                //NSLog(@"number of columns =%d",sqlite3_column_count(statement));
                int numberOfColumns=sqlite3_column_count(statement);
                
                for(int i=0; i<numberOfColumns;i++ )
                {
                    char *_tempChar = (char *) sqlite3_column_text(statement, i);
                    char *_tempCol  = (char *) sqlite3_column_name(statement, i);
                    NSString *value;
                    NSString *column;
                    
                    if (_tempChar==NULL)
                    {
                        value=@"";
                    }
                    else
                    {
                        value=[NSString stringWithUTF8String:_tempChar];
                    }
                    column = [NSString stringWithUTF8String:_tempCol];
                    
                    //NSLog(@"%@",value);
                    [tempDisc setObject:value forKey:column];
                  stringToReturn=[tempDisc valueForKey:column];
                    //					[tempDisc setObject:value forKey:[NSString stringWithFormat:@"%d",i]];
                }
                
                //[arrayToReturn addObject:tempDisc];
                
                
            }
            
        }
        else
        {
            //			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
        }
        sqlite3_finalize(statement);
        sqlite3_close(db);
    }
    
    
    
    [_lock unlock];
    
    
    return stringToReturn ;
    
}

#pragma mark - Get Data
-(NSMutableArray *)getData:(NSString*)tableID where:(NSString *)whereClause
{
    
    NSLock *_lock = [NSLock new] ;
    [_lock lock];
    
    
    NSMutableArray *arrayToReturn=[[NSMutableArray alloc]init] ;
    NSString *query;
    
    if (whereClause == nil) {
        query = [NSString stringWithFormat:@"SELECT * FROM %@ ",tableID];
    }
    else {
        query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@",tableID, whereClause];
    }
    
    NSLog(@"query =========> %@",query);
    
    [ self openDb];
    
    sqlite3_close(db);
    
    if((sqlite3_open([databasePath UTF8String], &db))==SQLITE_OK)
    {
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, NULL)==SQLITE_OK)
        {
            while(sqlite3_step(statement)==SQLITE_ROW)
            {
                NSMutableDictionary *tempDisc=[[NSMutableDictionary alloc] init];
                //NSLog(@"number of columns =%d",sqlite3_column_count(statement));
                int numberOfColumns=sqlite3_column_count(statement);
                
                for(int i=0; i<numberOfColumns;i++ )
                {
                    char *_tempChar = (char *) sqlite3_column_text(statement, i);
                    char *_tempCol  = (char *) sqlite3_column_name(statement, i);
                    NSString *value;
                    NSString *column;
                    
                    if (_tempChar==NULL)
                    {
                        value=@"";
                    }
                    else
                    {
                        value=[NSString stringWithUTF8String:_tempChar];
                    }
                    column = [NSString stringWithUTF8String:_tempCol];
                    
                    //NSLog(@"%@",value);
                    [tempDisc setObject:value forKey:column];
                    //					[tempDisc setObject:value forKey:[NSString stringWithFormat:@"%d",i]];
                }
                [arrayToReturn addObject:tempDisc];
                
                
            }
            
        }
        else
        {
            //			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
        }
        sqlite3_finalize(statement);
        sqlite3_close(db);
    }
    
    
    
    [_lock unlock];
    
    
    return arrayToReturn ;
}



-(BOOL)removeObject:(NSString *)tableID Where:(NSString*)whereClause
{
    //    NSLog(@"DataBase Path--->%@",databasePath);
    NSLock *_lock = [NSLock new];
    [_lock lock];
    
    BOOL _success=NO;
    [self openDb];
    sqlite3_close(db);
    if(sqlite3_open([databasePath UTF8String], &db)==SQLITE_OK)
    {
        
        sqlite3_stmt *delete_statement;
        
        NSString *query;
        
        if(whereClause!=nil && ![whereClause isEqual:@""]){
            query = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@", tableID, whereClause];
        }
        else{
            query = [NSString stringWithFormat:@"DELETE FROM %@", tableID];
        }
        
        //NSLog(@"Delete Query =====>  %@",query);
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &delete_statement, NULL) != SQLITE_OK)
        {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
        }
        
        int success = sqlite3_step(delete_statement);
        
        sqlite3_finalize(delete_statement);
        sqlite3_close(db);
        if (success != SQLITE_ERROR)
        {
            _success=YES;
        }
        else
        {
            _success=NO;
        }
    }
    
    [_lock unlock];
    
    return _success;
}
#pragma mark-getData with query
-(NSMutableArray *)getDataWithQuery:(NSString*)Query
{
//    NSLock *_lock = [NSLock new];
//    [_lock lock];
    
    NSMutableArray *arrayToReturn=[[NSMutableArray alloc]init];
    NSString *query;
//    sqlite3 *db;
    
    query = [NSString stringWithFormat:@"%@",Query];
    
    NSLog(@"query =========> %@",query);
    [ self openDb];
    sqlite3_close(db);
    if((sqlite3_open([databasePath UTF8String], &db)) == SQLITE_OK)
    {
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            while(sqlite3_step(statement) == SQLITE_ROW)
//            while(sqlite3_step(statement) == SQLITE_DONE)
            {
                NSMutableDictionary *tempDisc=[[NSMutableDictionary alloc] init];
                //NSLog(@"number of columns =%d",sqlite3_column_count(statement));
                int numberOfColumns=sqlite3_column_count(statement);
                for(int i=0; i<numberOfColumns;i++ )
                {
                    char *_tempChar = (char *) sqlite3_column_text(statement, i);
                    char *_tempCol  = (char *) sqlite3_column_name(statement, i);
                    NSString *value;
                    NSString *column;
                    
                    if (_tempChar==NULL)
                    {
                        value=@"";
                    }
                    else
                    {
                        value=[NSString stringWithUTF8String:_tempChar];
                    }
                    column = [NSString stringWithUTF8String:_tempCol];
                    
                    //NSLog(@"%@",value);
                    [tempDisc setObject:value forKey:column];
                    //					[tempDisc setObject:value forKey:[NSString stringWithFormat:@"%d",i]];
                }
                [arrayToReturn addObject:tempDisc];
            }
        }
        else
        {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
        }
        sqlite3_finalize(statement);
        sqlite3_close(db);
    }
    
    
    
//    [_lock unlock];
    
    
    return arrayToReturn ;
}

-(int)insertDataInBulk:(NSString*)table_ID : (NSMutableArray *) dataArray{
    
   // NSLog(@"table_id %@",table_ID);
    
    NSLock *_lock = [NSLock new];
    
    [_lock lock];
    
    int rowId = -1;
    [ self openDb];
    sqlite3_close(db);
    
    if (sqlite3_open([databasePath UTF8String], &db) == SQLITE_OK) {
        
        //  NSLog(@"insertDataInBulk -> total DATA INSERTED IN LOCAL DB %lu",(unsigned long)[ dataArray count]);
        for (int i=0; i<dataArray.count; i++) {
            NSMutableDictionary *data=[NSMutableDictionary dictionaryWithDictionary:[dataArray objectAtIndex:i]];
          //  NSLog(@"dataDictionary %@",[data description]);
            sqlite3_stmt *addStmt;
            
            NSString *key = nil;
            NSString *value = nil;
            
            for (NSString *k in [data allKeys]) {
                
                
                
                if ([k isEqualToString:@"id"] || [k isEqualToString:@"name"] || [k isEqualToString:@"mobileNo"] || [k isEqualToString:@"modifiedNo"] || [k isEqualToString:@"ISDCode"] || [k isEqualToString:@"iPrayUser"])
                {
                    key = (key == nil)?[NSString stringWithString:k] : [key stringByAppendingFormat:@",%@",k];
                    value =(value == nil)?[NSString stringWithFormat:@"'%@'",[data valueForKey:k]]:[value stringByAppendingString:[NSString stringWithFormat:@",'%@'",[data valueForKey:k]]];
                }
            
            }
            
            
            NSString *query = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES(%@)", table_ID, key, value];
            [query stringByReplacingOccurrencesOfString:@"'" withString:@""];
            //        query = [query stringByReplacingOccurrencesOfString:@"'" withString:@""];
            //NSLog(@"Insert query = %@",query);
            
         //   NSLog(@"%d",sqlite3_prepare_v2(db, [query UTF8String], -1, &addStmt, NULL));
            if(sqlite3_prepare_v2(db, [query UTF8String], -1, &addStmt, NULL) == SQLITE_OK){
                
                //            [self createValues:addStmt :data];
                
                if(SQLITE_DONE == sqlite3_step(addStmt)){
                  //  NSLog(@"PRO_DB_INSERT=====> Record Inserted Successfully");
                    rowId = (int)sqlite3_last_insert_rowid(db);
                   // NSLog(@"RowId While Inserting %d",rowId);
                }
                else{
                   // NSLog(@"PRO_DB_INSERT =====> Error while adding record. '%s'", sqlite3_errmsg(db));
                }
            }
            else {
                NSLog(@"PRO_DB_INSERT =====> Error while preapring statement. '%s'", sqlite3_errmsg(db));
            }
            sqlite3_finalize(addStmt);
        }
        
        sqlite3_close(db);
    }
    else {
      //  NSLog(@"PRO_DB_INSERT =====> Error while opening database '%s'", sqlite3_errmsg(db));
    }
    
    
    [_lock unlock];
    
    return rowId;
    
}
#pragma mark-get Count With Query
-(int)getCunt:(NSString *)Query
{
    int count=0;
    //NSLog(@"query =========> %@",Query);
    [self openDb];
    sqlite3_close(db);
    
    if((sqlite3_open([databasePath UTF8String], &db))==SQLITE_OK)
    {
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(db, [Query UTF8String], -1, &statement, NULL)==SQLITE_OK)
        {
            while(sqlite3_step(statement)==SQLITE_ROW)
            {
                
                count = sqlite3_column_int(statement, 0);
                
            }
        }
        else
        {
            NSLog(@"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
        }
        sqlite3_finalize(statement);
        sqlite3_close(db);
    }
    
    
    return count;
}
@end
