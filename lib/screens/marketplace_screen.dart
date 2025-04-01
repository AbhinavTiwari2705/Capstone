import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/marketplace_model.dart';
import 'package:url_launcher/url_launcher.dart';

class MarketplaceScreen extends StatefulWidget {
  @override
  _MarketplaceScreenState createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  List<MarketplaceItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMarketplaceItems();
  }

  Future<void> _loadMarketplaceItems() async {
    // Simulated data with publicly accessible images
    final items = [
      MarketplaceItem(
        id: 1,
        serviceName: "Tractor for Ploughing",
        description: "Well-maintained tractor suitable for ploughing fields, ideal for both small and large farms.",
        ownerName: "Ramesh Yadav",
        contact: "+91 9876543210",
        location: "Madhya Pradesh, India",
        perDayCost: 1500,
        imageUrl: "https://images.unsplash.com/photo-1605338803155-8b0397986b88?w=800",
        availability: "Available",
      ),
      MarketplaceItem(
        id: 2,
        serviceName: "Harvester for Rent",
        description: "High-efficiency harvester available for crop harvesting, best suited for wheat and rice fields.",
        ownerName: "Suresh Kumar",
        contact: "+91 8765432109",
        location: "Punjab, India",
        perDayCost: 5000,
        imageUrl: "https://images.unsplash.com/photo-1588183065094-fb6a6c2d5e06?w=800",
        availability: "Available",
      ),
      MarketplaceItem(
        id: 3,
        serviceName: "Irrigation Pump Rental",
        description: "Diesel-powered irrigation pump suitable for long-duration watering needs.",
        ownerName: "Amit Sharma",
        contact: "+91 7654321098",
        location: "Uttar Pradesh, India",
        perDayCost: 700,
        imageUrl: "https://images.pexels.com/photos/2255801/pexels-photo-2255801.jpeg?w=800",
        availability: "Rented Out",
      ),
      MarketplaceItem(
        id: 4,
        serviceName: "Seed Sowing Machine",
        description: "Automatic seed sowing machine available for efficient planting, covering large areas quickly.",
        ownerName: "Vikas Patel",
        contact: "+91 6543210987",
        location: "Haryana, India",
        perDayCost: 2500,
        imageUrl: "https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=800",
        availability: "Available",
      ),
    ];

    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  void _showAddItemDialog() {
    final _formKey = GlobalKey<FormState>();
    String serviceName = '';
    String description = '';
    String ownerName = '';
    String contact = '';
    String location = '';
    double perDayCost = 0;
    String imageUrl = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.addNewItem),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.serviceName),
                  validator: (value) => value?.isEmpty ?? true ? AppLocalizations.of(context)!.required : null,
                  onSaved: (value) => serviceName = value ?? '',
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.description),
                  validator: (value) => value?.isEmpty ?? true ? AppLocalizations.of(context)!.required : null,
                  onSaved: (value) => description = value ?? '',
                  maxLines: 3,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.ownerName),
                  validator: (value) => value?.isEmpty ?? true ? AppLocalizations.of(context)!.required : null,
                  onSaved: (value) => ownerName = value ?? '',
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.contact),
                  validator: (value) => value?.isEmpty ?? true ? AppLocalizations.of(context)!.required : null,
                  onSaved: (value) => contact = value ?? '',
                  keyboardType: TextInputType.phone,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.location),
                  validator: (value) => value?.isEmpty ?? true ? AppLocalizations.of(context)!.required : null,
                  onSaved: (value) => location = value ?? '',
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.perDayCost),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return AppLocalizations.of(context)!.required;
                    if (double.tryParse(value!) == null) return AppLocalizations.of(context)!.enterValidAmount;
                    return null;
                  },
                  onSaved: (value) => perDayCost = double.tryParse(value ?? '0') ?? 0,
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.imageUrl),
                  validator: (value) => value?.isEmpty ?? true ? AppLocalizations.of(context)!.required : null,
                  onSaved: (value) => imageUrl = value ?? '',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                _formKey.currentState?.save();
                final newItem = MarketplaceItem(
                  id: _items.length + 1,
                  serviceName: serviceName,
                  description: description,
                  ownerName: ownerName,
                  contact: contact,
                  location: location,
                  perDayCost: perDayCost,
                  imageUrl: imageUrl,
                  availability: "Available",
                );
                setState(() {
                  _items.add(newItem);
                });
                Navigator.pop(context);
              }
            },
            child: Text(AppLocalizations.of(context)!.add),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.marketplace),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddItemDialog,
            tooltip: AppLocalizations.of(context)!.addNewItem,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                          child: Image.network(
                            item.imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image_not_supported, size: 50, color: Colors.grey[400]),
                                    SizedBox(height: 8),
                                    Text(
                                      AppLocalizations.of(context)!.imageNotAvailable,
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.serviceName,
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: item.availability == "Available"
                                        ? Colors.green
                                        : Colors.red,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item.availability,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              '₹${item.perDayCost}/day',
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            SizedBox(height: 8),
                            Text(item.description),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(Icons.person, size: 16),
                                SizedBox(width: 4),
                                Text(item.ownerName),
                                SizedBox(width: 16),
                                Icon(Icons.location_on, size: 16),
                                SizedBox(width: 4),
                                Text(item.location),
                              ],
                            ),
                            SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => _makePhoneCall(item.contact),
                              icon: Icon(Icons.phone),
                              label: Text(AppLocalizations.of(context)!.contact),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
