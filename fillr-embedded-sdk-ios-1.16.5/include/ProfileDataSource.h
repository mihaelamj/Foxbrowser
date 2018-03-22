//
//  ProfileDataSource.h
//  POP
//
//  Created by Alex Bin Zhao on 2/06/2016.
//  Copyright © 2016 POP TECH Pty. Ltd. All rights reserved.
//

#import "ProfileElement.h"
#import "Heading.h"

@class ProfileElement;

@protocol ProfileDataSource<NSObject>

- (NSDictionary *)allUserProfileValues;
- (id)userProfileValueForFieldName:(NSString *)fieldNamespace;
- (void)saveToUserProfile:(NSDictionary *)dictionary;
- (void)saveToUserProfile:(NSDictionary *)dictionary isBatchProcess:(BOOL)isBatchProcess;
- (void)persist;

- (NSArray *)searchProfileValueStartFieldName:(NSString *)fieldNamespace;
- (void)removeProfileValueForFieldNamespaces:(NSArray *)namespaces;

- (NSUInteger)profileCountForArray:(Heading *)arrayHeading;
- (NSArray *)allIndexesForArray:(Heading *)arrayHeading;
- (NSUInteger)getProfileCount;
- (void)travelThroughElementHierarchy:(Heading *)heading childrenValues:(NSMutableArray *)childrenValues arrayNamespace:(NSString *)arrayNamespace objectNamespace:(NSString *)objectNamespace;
- (void)travelThroughElementHierarchy:(Heading *)heading childrenValues:(NSMutableArray *)childrenValues arrayNamespace:(NSString *)arrayNamespace objectNamespace:(NSString *)objectNamespace excludePasswordNick:(BOOL)exclude;
- (void)removeEmptyProfileElementsForParentHeading:(Heading *)parentHeading;
- (void)removeProfileArrayObject:(id)arrayObject arrayInternalIndex:(NSUInteger)arrayInternalIndex;
- (void)copyElementValueFrom:(ProfileElement *)copyFromElement toElement:(ProfileElement *)copyToElement;

// Wrapper methods for Profile Engine
- (NSArray *)allProfileElementsForArray:(Heading *)arrayHeading;
- (NSArray *)allProfileElementsForParentHeading:(Heading *)parentHeading;
- (NSString *)profileEmailAddress;
- (NSString *)profileFirstName;
- (NSString *)profileLastName;
- (void)addNewObjectToArray:(Heading *)parentHeading;
- (void)addNewObjectToArray:(Heading *)parentHeading isBatchProcess:(BOOL)isBatchProcess;
- (BOOL)isArrayObjectIndexUsedInProfile:(Heading *)arrayHeading arrayInternalIndex:(NSUInteger)arrayInternalIndex;
- (void)clearAllDataForArray:(Heading *)arrayHeading;

@end
