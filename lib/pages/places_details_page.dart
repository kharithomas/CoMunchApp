import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';

const kGoogleApiKey = 'AIzaSyACwvAsVU8fapm3Pvyffg_5uGuvTIKPRIY';
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

extension CapExtension on String {
  String get inCaps => '${this[0].toUpperCase()}${this.substring(1)}';
  String get allInCaps => this.toUpperCase();
  String get titleCase => this.split(" ").map((str) => str.inCaps).join(" ");
}

class PlacesDetailsPage extends StatefulWidget {
  final String placeId;
  final String imageRef;
  final double lat; // reconfigure to remove these
  final double lng; // reconfigure to remove these

  // Constructor
  PlacesDetailsPage({
    @required this.placeId,
    this.imageRef,
    this.lat,
    this.lng,
  });

  @override
  State<StatefulWidget> createState() {
    return PlacesDetailState();
  }
}

class PlacesDetailState extends State<PlacesDetailsPage> {
  PlacesDetailsResponse _place;
  bool _isLoading = false;
  String _errorLoading;

  // Launch device native Maps
  void _launchMapsUrl(double lat, double lng) async {
    final googleMapsUrl = "comgooglemaps://?center=$lat,$lng";
    final appleMapsUrl = 'https://maps.apple.com/?q=$lat,$lng';

    // if Android device
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    }
    // if iOS device
    if (await canLaunch(appleMapsUrl)) {
      await launch(appleMapsUrl, forceSafariVC: false);
    } else {
      throw 'Could not launch Maps URL';
    }
  }

  // Returns the photoURL of location image - remove me or below me
  String buildPhotoURL(String photoReference) {
    return "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$kGoogleApiKey";
  }

  // Converts photoRef to main image
  Image getMainImage(String photoRef) {
    const endpoint = 'https://maps.googleapis.com/maps/api/place/photo';
    final maxWidth = 300;

    // construct our url link
    final url =
        "$endpoint?maxwidth=$maxWidth&photoreference=$photoRef&key=$kGoogleApiKey";

    return Image.network(url,
        fit: BoxFit.cover, height: 365, width: double.infinity);
  }

  // Opens share dialog with lat lng
  void _shareLatLng(BuildContext context, double lat, double lng) {
    final RenderBox box = context.findRenderObject();
    final String text = 'Come check out this restaurant with me!';
    final String subject = '\n$lat, $lng';

    Share.share(
      text,
      subject: subject,
      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
    );
  }

  @override
  void initState() {
    fetchPlaceDetail();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyChild;

    if (_isLoading) {
      bodyChild = Center(
        child: CircularProgressIndicator(
          value: null,
        ),
      );
    } else if (_errorLoading != null) {
      bodyChild = Center(
        child: Text(_errorLoading),
      );
    } else {
      final placeDetail = _place.result;
      bodyChild = buildPlaceDetailList(placeDetail);
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            iconTheme: IconThemeData(color: Colors.black),
            backgroundColor: Colors.transparent,
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: getMainImage(widget.imageRef),
            ),
          ),
          SliverFillRemaining(
            child: bodyChild,
          ),
        ],
      ),
      // Positioned(
      //   top: (MediaQuery.of(context).size.width / 1.6),
      //   right: 12,
      //   child: Card(
      //     color: Colors.black,
      //     shape: RoundedRectangleBorder(
      //         borderRadius: BorderRadius.circular(50.0)),
      //     elevation: 3.0,
      //     child: Container(
      //       width: 55,
      //       height: 55,
      //       child: Center(
      //         child: IconButton(
      //           onPressed: () {},
      //           icon: Icon(
      //             Icons.share,
      //             size: 30,
      //           ),
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
    );
  }

  void fetchPlaceDetail() async {
    setState(() {
      this._isLoading = true;
      this._errorLoading = null;
    });

    PlacesDetailsResponse place =
        await _places.getDetailsByPlaceId(widget.placeId);

    if (mounted) {
      setState(() {
        this._isLoading = false;
        (place.status == 'OK')
            ? this._place = place
            : this._errorLoading = place.errorMessage;
      });
    }
  }

  ListView buildPlaceDetailList(PlaceDetails placeDetail) {
    List<Widget> list = [];
    // list.add(Padding(
    //   padding: EdgeInsets.symmetric(horizontal: 15.0),
    //   child: FlatButton(
    //     onPressed: () => _shareLatLng(context, widget.lat, widget.lng),
    //     child: Icon(Icons.ios_share),
    //   ),
    // ));

    // restaurant name / distance
    list.add(
      Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 4.0),
        child: Text(
          placeDetail.name,
          style: GoogleFonts.openSans(
              fontWeight: FontWeight.bold, fontSize: 30, color: Colors.black),
        ),
      ),
    );

    // restaurant types
    if (placeDetail.types != null) {
      list.add(
        Padding(
          padding: const EdgeInsets.only(
              top: 8.0, left: 8.0, right: 8.0, bottom: 4.0),
          child: Text(
            placeDetail.types.length > 3
                ? placeDetail.types.sublist(0, 3).join(', ').titleCase
                : placeDetail.types.join(', ').titleCase,
            style: GoogleFonts.openSans(
              fontSize: 15,
              color: Color(0xff7C7C7C),
            ),
          ),
        ),
      );
    }

    // restuarant ratings
    if (placeDetail.rating != null) {
      list.add(
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
          child: Row(
            children: [
              _buildRatingBar(placeDetail.rating),
              SizedBox(width: 16),
              Text(
                '${placeDetail.reviews.length} Reviews',
                style: GoogleFonts.openSans(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // restaurant price / availability
    if (placeDetail.openingHours != null && placeDetail.priceLevel != null) {
      list.add(
        Padding(
          padding: const EdgeInsets.only(
              top: 8.0, left: 8.0, right: 8.0, bottom: 4.0),
          child: Row(
            children: [
              _buildMoneySigns(placeDetail.priceLevel.index),
              Text(
                ' • ${placeDetail.openingHours.openNow ? 'Open Now' : 'Closed'}',
                style: GoogleFonts.openSans(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }

    // restaurant address
    if (placeDetail.formattedAddress != null) {
      list.add(
        Padding(
          padding: const EdgeInsets.only(
              top: 8.0, left: 8.0, right: 8.0, bottom: 4.0),
          child: Text(
            placeDetail.formattedAddress,
            style: GoogleFonts.openSans(
              color: Color(0xff7C7C7C),
              fontSize: 15,
            ),
          ),
        ),
      );
    }

    //get directions
    list.add(
      Padding(
        padding:
            const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0, bottom: 4.0),
        child: FlatButton(
          child: Text(
            'Get Directions'.toUpperCase(),
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black),
          ),
          onPressed: () => _launchMapsUrl(widget.lat, widget.lng),
        ),
      ),
    );

    //call restaurant
    list.add(
      Padding(
        padding:
            const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0, bottom: 4.0),
        child: FlatButton(
          color: Color(0xffEEEEEF),
          child: Text(
            'Call Restaurant'.toUpperCase(),
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xffF78C39)),
          ),
          onPressed: () => launch("tel:${placeDetail.formattedPhoneNumber}"),
        ),
      ),
    );

    list.add(Padding(
      padding:
          const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0, bottom: 4.0),
      child: Text(
        'Reviews',
        style: GoogleFonts.openSans(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    ));

    // List the reviews
    if (placeDetail.reviews != null) {
      list.add(
        SizedBox(
          height: 200.0,
          child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemCount:
                placeDetail.reviews.length < 3 ? placeDetail.reviews.length : 3,
            itemBuilder: (context, i) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      child:
                          Image.network(placeDetail.reviews[i].profilePhotoUrl),
                    ),
                    title: Text(placeDetail.reviews[i].authorName),
                    subtitle:
                        Text(placeDetail.reviews[i].relativeTimeDescription),
                    isThreeLine: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(placeDetail.reviews[i].text),
                  ),
                ],
              );
            },
          ),
        ),
      );
    }

    return ListView(
      shrinkWrap: true,
      children: list,
      physics: NeverScrollableScrollPhysics(),
    );
  }

  Widget _buildRatingBar(num rating) {
    var stars = <Widget>[];
    for (var i = 1; i <= 5; i++) {
      var color = i <= rating ? Color(0xffF78C39) : Color(0xffCCCCCC);
      var star = Icon(
        Icons.star,
        color: color,
      );
      stars.add(star);
    }
    return Row(children: stars);
  }

  Widget _buildMoneySigns(int price) {
    var signs = <Widget>[];
    for (var i = 0; i < price; i++) {
      var sign = Icon(
        Icons.attach_money,
        color: Color(0xff2BC128),
        size: 18,
      );
      signs.add(sign);
    }
    return Row(children: signs);
  }
}
