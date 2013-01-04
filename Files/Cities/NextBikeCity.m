//
//  NextBikeCity.m
//  Bicyclette
//
//  Created by Nicolas on 24/12/12.
//  Copyright (c) 2012 Nicolas Bouilleaud. All rights reserved.
//

#import "BicycletteCity.h"

#import "BicycletteCity.mogenerated.h"
#import "NSObject+KVCMapping.h"
#import "CollectionsAdditions.h"
#import "NSStringAdditions.h"

@interface NextBikeCity : _BicycletteCity <BicycletteCity,NSXMLParserDelegate>
@end

@implementation NextBikeCity
{
    NSManagedObjectContext * _parsing_context;
    NSMutableArray * _parsing_oldStations;
    Region * _parsing_region;
}

- (void) parseData:(NSData *)data
     fromURLString:(NSString*)urlString
         inContext:(NSManagedObjectContext*)context
       oldStations:(NSMutableArray*)oldStations
{
    _parsing_context = context;
    _parsing_oldStations = oldStations;
    
    // Create an anonymous region
    _parsing_region = [self regionForDataFromURL:urlString inContext:_parsing_context];
    
    // Parse stations XML
    NSXMLParser * parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    [parser parse];
    
    _parsing_region = nil;
    _parsing_context = nil;
    _parsing_oldStations = nil;
}

- (NSDictionary*) KVCMapping
{
    return @{@"uid" : StationAttributes.number,
             @"name" : StationAttributes.name,
             @"lat" : StationAttributes.latitude,
             @"lng": StationAttributes.longitude,
             @"bikes": StationAttributes.status_available
             };
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"place"])
    {
        // Find Existing Station
        Station * station = [_parsing_oldStations firstObjectWithValue:attributeDict[@"id"] forKeyPath:StationAttributes.number];
        if(station)
        {
            // found existing
            [_parsing_oldStations removeObject:station];
        }
        else
        {
            if(_parsing_oldStations.count && [[NSUserDefaults standardUserDefaults] boolForKey:@"BicycletteLogParsingDetails"])
                NSLog(@"Note : new station found after update : %@", attributeDict);
            station = [Station insertInManagedObjectContext:_parsing_context];
        }
        
        // Set Values
		[station setValuesForKeysWithDictionary:attributeDict withMappingDictionary:[self KVCMapping]]; // Yay!
        
        station.status_totalValue = station.status_freeValue + station.status_availableValue;
        station.status_date = [NSDate date];
        
        // Set Station
        station.region = _parsing_region;
    }
}

/****************************************************************************/
#pragma mark Regions

- (BOOL) hasRegions { return self.serviceInfo[@"regions"]!=nil;
}

- (NSString*) titleForRegion:(Region*)region { return region.name; }
- (NSString*) subtitleForRegion:(Region*)region { return nil; }

- (Region*) regionForDataFromURL:(NSString*)urlString inContext:(NSManagedObjectContext*)context
{
    NSString * number = [self hasRegions] ? [urlString stringByDeletingPrefix:self.serviceInfo[@"update_url"]] : @"anonymousregion";
    NSString * name = [self hasRegions] ? self.serviceInfo[@"regions"][number] : @"anonymousregion";
    
    Region * region = [[Region fetchRegionWithNumber:context number:number] lastObject];
    if(region==nil)
    {
        region = [Region insertInManagedObjectContext:context];
        region.number = number;
        region.name = name;
    }
    return region;
}

- (NSArray *)updateURLStrings
{
    if( self.serviceInfo[@"regions"] == nil)
    {
        return [super updateURLStrings];
    }
    else
    {
        NSString * baseURL = self.serviceInfo[@"update_url"];
        NSDictionary * regions = self.serviceInfo[@"regions"];
        NSMutableArray * result = [NSMutableArray new];
        for (NSString * regionID in regions) {
            [result addObject:[baseURL stringByAppendingString:regionID]];
        }
        return result;
    }
}


@end
