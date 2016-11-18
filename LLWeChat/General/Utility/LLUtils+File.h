//
//  LLUtils+File.h
//  LLWeChat
//
//  Created by GYJZH on 9/10/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLUtils.h"

@interface LLUtils (File)

+ (NSString *)homeDirectory;

+ (NSString *)documentDirectory;

+ (NSString *)cacheDirectory;

+ (NSString *)tmpDirectory;

+ (UIStoryboard *)mainStoryboard;

+ (NSString *)messageThumbnailDirectory;

+ (NSURL *)createFolderWithName:(NSString *)folderName inDirectory:(NSString *)directory;

+ (NSString *)dataPath;

+ (void)removeFileAtPath:(NSString *)path;

+ (void)writeImageAtPath:(NSString *)path image:(UIImage *)image;

/**
 *  返回文件大小，单位为字节
 */
+ (unsigned long long)getFileSize:(NSString *)path;

@end
