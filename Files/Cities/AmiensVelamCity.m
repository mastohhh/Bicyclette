//
//  AmiensVelamCity.m
//  Bicyclette
//
//  Created by Nicolas on 17/10/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "AmiensVelamCity.h"
#import "Station.h"
#import "Region.h"

@implementation AmiensVelamCity

- (RegionInfo*) regionInfoFromStation:(Station*)station patchs:(NSDictionary*)patchs
{
    RegionInfo * regionInfo = [RegionInfo new];
    regionInfo.number = @"Amiens";
    regionInfo.name = @"Vélam";
    
    return regionInfo;
}

- (NSString*)titleForRegion:(Region*)region
{
    return @"Amiens";
}

- (NSString*)subtitleForRegion:(Region*)region
{
    return @"Vélam";
}

- (NSString*)titleForStation:(Station*)region
{
    // remove number
    NSString * shortname = region.name;
    NSRange beginRange = [shortname rangeOfString:@"-"];
    if (beginRange.location!=NSNotFound)
        shortname = [region.name substringFromIndex:beginRange.location+beginRange.length];
    
    // remove whitespace
    shortname = [shortname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // capitalized
    if([shortname respondsToSelector:@selector(capitalizedStringWithLocale:)])
        shortname = [shortname capitalizedStringWithLocale:[NSLocale currentLocale]];
    else
        shortname = [shortname stringByReplacingCharactersInRange:NSMakeRange(1, shortname.length-1) withString:[[shortname substringFromIndex:1] lowercaseString]];
    
    return shortname;
}

@end
