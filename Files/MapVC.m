//
//  MapVC.m
//  Bicyclette
//
//  Created by Nicolas on 04/12/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import "MapVC.h"
#import "BicycletteApplicationDelegate.h"
#import "VelibDataManager.h"
#import "Station.h"
#import "Region.h"
#import "StationDetailVC.h"

typedef enum {
	MapModeNone = 0,
	MapModeRegions,
	MapModeStations
}  MapMode;

@interface MapVC() <MKMapViewDelegate>
@property (nonatomic) MKCoordinateRegion referenceRegion;
@property (nonatomic) MapMode mode;
- (void) showDetails:(MKAnnotationView*)sender;
- (void) zoomIn:(Region*)region;
@end

/****************************************************************************/
#pragma mark -

@implementation MapVC 

@synthesize mapView;
@synthesize referenceRegion, mode;

- (void)dealloc {
    [super dealloc];
}

/****************************************************************************/
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.referenceRegion = [self.mapView regionThatFits:BicycletteAppDelegate.dataManager.coordinateRegion];
	self.mapView.region = self.referenceRegion;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

/****************************************************************************/
#pragma mark MapView Delegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	CLLocationDegrees modelSpan = self.referenceRegion.span.latitudeDelta;
	if(self.mapView.region.span.latitudeDelta>modelSpan*2.0f)
		self.mode = MapModeNone;
	else if(self.mapView.region.span.latitudeDelta>modelSpan/10.0f)
		self.mode = MapModeRegions;
	else
		self.mode = MapModeStations;
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	if([annotation isKindOfClass:[MKUserLocation class]])
		return nil;
	else if([annotation isKindOfClass:[Region class]])
	{
		NSString* identifier = NSStringFromClass([Region class]);
		MKPinAnnotationView * pinView = (MKPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
		if(nil==pinView)
		{
			pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
			pinView.pinColor = MKPinAnnotationColorPurple;
			pinView.canShowCallout = NO;
		}
		return pinView;
	}
	else if([annotation isKindOfClass:[Station class]])
	{
		NSString* identifier = NSStringFromClass([Station class]);
		MKPinAnnotationView * pinView = (MKPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
		if(nil==pinView)
		{
			pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
			pinView.pinColor = MKPinAnnotationColorGreen;
			pinView.canShowCallout = YES;
			UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
			[rightButton addTarget:self
							action:@selector(showDetails:)
				  forControlEvents:UIControlEventTouchUpInside];
			pinView.rightCalloutAccessoryView = rightButton;
		}
		return pinView;
	}
	return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
	Region * region = (Region*)view.annotation;
	if([region isKindOfClass:[Region class]])
	{
		[self zoomIn:region];
	}
}

/****************************************************************************/
#pragma mark Actions

- (void) setMode:(MapMode)value
{
	if(value!=self.mode)
	{
		mode = value;
		[self.mapView removeAnnotations:self.mapView.annotations];
		if(self.mode==MapModeNone)
			return;
		NSFetchRequest * request = [[NSFetchRequest new] autorelease];
		Class class = self.mode==MapModeRegions?[Region class]:[Station class];
		[request setEntity:[class entityInManagedObjectContext:BicycletteAppDelegate.dataManager.moc]];
		[self.mapView addAnnotations:[BicycletteAppDelegate.dataManager.moc executeFetchRequest:request error:NULL]];
	}
}


- (void) showDetails:(UIButton*)sender
{
	Station * station = (Station*)[self.mapView.selectedAnnotations objectAtIndex:0];
	
	[self.navigationController pushViewController:[StationDetailVC detailVCWithStation:station inArray:nil] animated:YES];
}

- (void) zoomIn:(Region*)region
{
	[self.mapView setRegion:[self.mapView regionThatFits:region.coordinateRegion] animated:YES];
}

@end
