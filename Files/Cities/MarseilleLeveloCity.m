//
//  MarseilleLeveloCity.m
//  Bicyclette
//
//  Created by Nicolas on 14/10/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "MarseilleLeveloCity.h"
#import "Station.h"
#import "Region.h"

@implementation MarseilleLeveloCity

- (RegionInfo*) regionInfoFromStation:(Station*)station patchs:(NSDictionary*)patchs
{
    RegionInfo * regionInfo = [RegionInfo new];
    regionInfo.number = [station.name substringToIndex:1];
    regionInfo.name = [station.name substringToIndex:1];
    
    return regionInfo;
}

- (NSString*)titleForRegion:(Region*)region
{
    return [NSString stringWithFormat:@"%@°",region.number];
}

- (NSString*)subtitleForRegion:(Region*)region
{
    return @"arr.";
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
