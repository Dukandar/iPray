//
//  DatabaseHandler.h
//
//
//  Created by development6 on 30/06/17.
//  Copyright (c) 2014 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>



@interface DatabaseHandler : NSObject
{
    sqlite3 *db;
}
-(void)autoInsertUpdate:(NSString*)tableName Data:(NSDictionary*)data Where:(NSString*)whereClause;
-(NSMutableArray *)getData:(NSString*)tableID where:(NSString *)whereClause;
-(NSMutableString *)getSigalData:(NSString*)tableID data:(NSString*)data where:(NSString *)whereClause;
-(BOOL)removeObject:(NSString *)tableID Where:(NSString*)whereClause;
-(NSMutableArray *)getDataWithQuery:(NSString*)Query;
-(int)insertDataInBulk:(NSString*)table_ID : (NSMutableArray *) dataArray;
-(int)getCunt:(NSString *)Query;
-(BOOL)isRecordExist:(NSString *)tableName where :(NSString *)where;
@end
