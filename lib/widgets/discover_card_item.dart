/// TODO: Move places API key to a seperate file - for security

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../pages/places_details_page.dart';

const PLACES_API_KEY = 'AIzaSyACwvAsVU8fapm3Pvyffg_5uGuvTIKPRIY';

class DiscoverCardItem extends StatefulWidget {
  final String id;
  final String name;
  final String imageRef;
  final double rating;
  final bool isOpen;
  final double lat;
  final double lng;

  DiscoverCardItem({
    this.id,
    this.name,
    this.imageRef,
    this.rating,
    this.isOpen,
    this.lat,
    this.lng,
  });

  @override
  _DiscoverCardItemState createState() => _DiscoverCardItemState();
}

class _DiscoverCardItemState extends State<DiscoverCardItem> {
  Image getMainImage(BuildContext context, String photoRef) {
    const endpoint = 'https://maps.googleapis.com/maps/api/place/photo';
    final maxWidth = 425;

    // construct our url link
    final url =
        "$endpoint?maxwidth=$maxWidth&photoreference=$photoRef&key=$PLACES_API_KEY";

    return Image.network(url,
        fit: BoxFit.cover,
        height: MediaQuery.of(context).size.height * 0.51,
        width: double.infinity);
  }

  @override
  Widget build(BuildContext context) {
    var _currentUser = Provider.of<User>(context);

    return Card(
      child: Stack(
        children: [
          Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlacesDetailsPage(
                        placeId: widget.id,
                        imageRef: widget.imageRef,
                        lat: widget.lat,
                        lng: widget.lng,
                      ),
                    ),
                  );
                },
                // image
                child: widget.imageRef != null
                    ? getMainImage(context, widget.imageRef)
                    : Image.asset(
                        'assets/images/img_not_available.jpeg',
                        fit: BoxFit.cover,
                        height: MediaQuery.of(context).size.height * 0.42,
                        width: double.infinity,
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // title
                    Text(
                      widget.name,
                      style: GoogleFonts.openSans(
                        color: Color(0xff222222),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                    // subtitle
                    // Text(
                    //   'Add Food Category Here',
                    //   style: GoogleFonts.openSans(
                    //     color: Color(0xffAAAAAA),
                    //     fontWeight: FontWeight.w600,
                    //     fontSize: 13,
                    //   ),
                    // ),
                    const SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // rating
                        Row(
                          children: [
                            Text(
                              widget.rating.toString(),
                              style: GoogleFonts.openSans(
                                color: Color(0xff222222),
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Icon(
                              Icons.star_rate,
                              color: Color(0xffFFD500),
                              size: 23,
                            ),
                          ],
                        ),
                        // currently open / closed
                        Text(
                          (widget.isOpen) ? 'Open Now' : 'Closed',
                          style: GoogleFonts.openSans(
                              color: Color(0xffE74D4D),
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // favorite icon
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              onPressed: () => _currentUser.toggleFavorite({
                'id': widget.id,
                'name': widget.name,
                'imageRef': widget.imageRef,
                'rating': widget.rating.toString(),
              }),
              icon: _currentUser.isFavoritePlace(widget.id)
                  ? Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 35,
                    )
                  : Icon(
                      Icons.favorite_outline,
                      color: Colors.white,
                      size: 35,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
