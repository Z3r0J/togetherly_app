import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../theme/app_colors.dart';
import '../widgets/widgets.dart';
import '../l10n/app_localizations.dart';

/// Location Picker View
///
/// This is a placeholder view for Google Maps location selection.
/// To implement full Google Maps functionality:
///
/// 1. Add google_maps_flutter package to pubspec.yaml:
///    ```yaml
///    dependencies:
///      google_maps_flutter: ^2.5.0
///      geocoding: ^2.1.1  # for address search
///    ```
///
/// 2. Configure API keys:
///    - Android: Add API key to android/app/src/main/AndroidManifest.xml
///      ```xml
///      <meta-data android:name="com.google.android.geo.API_KEY"
///                 android:value="YOUR_API_KEY"/>
///      ```
///    - iOS: Add API key to ios/Runner/AppDelegate.swift
///      ```swift
///      GMSServices.provideAPIKey("YOUR_API_KEY")
///      ```
///
/// 3. Replace this implementation with GoogleMap widget:
///    - Use GoogleMap widget with initial camera position
///    - Add markers for selected location
///    - Implement onTap to place/move marker
///    - Use geocoding package to convert coordinates to addresses
///    - Add search functionality with autocomplete

class LocationPickerView extends StatefulWidget {
  const LocationPickerView({super.key});

  @override
  State<LocationPickerView> createState() => _LocationPickerViewState();
}

class _LocationPickerViewState extends State<LocationPickerView> {
  final _searchController = TextEditingController();
  String? _selectedLocation;
  List<Map<String, dynamic>> _searchSuggestions = [];
  bool _showSuggestions = false;
  Timer? _debounceTimer;

  // Map related
  GoogleMapController? _mapController;
  LatLng _selectedPosition = const LatLng(
    18.4861,
    -69.9312,
  ); // Santo Domingo, DR
  String _selectedAddress = '';
  Set<Marker> _markers = {};
  bool _isMapAvailable = false;

  // Mock locations for demonstration when map not available
  final List<String> _mockLocations = [
    'Starbucks, Main Street',
    'Central Park',
    'City Library',
    'Community Center',
    'Coffee Shop Downtown',
    'Riverside Park',
    'Local Gym',
    'Pizza Place',
  ];

  List<String> _filteredLocations = [];

  @override
  void initState() {
    super.initState();
    print('🗺️ [LocationPicker] initState - Setting up Google Maps');
    // Google Maps is available (API key configured in AndroidManifest.xml)
    _isMapAvailable = true;
    _filteredLocations = _mockLocations;
    _searchController.addListener(_filterLocations);
    if (_isMapAvailable) {
      print('🗺️ [LocationPicker] Getting current location...');
      _getCurrentLocation();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      print('📍 [LocationPicker] Checking location permission...');
      LocationPermission permission = await Geolocator.checkPermission();
      print('   Permission status: $permission');

      if (permission == LocationPermission.denied) {
        print('   Requesting permission...');
        permission = await Geolocator.requestPermission();
        print('   New permission status: $permission');
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ [LocationPicker] Permission denied forever');
        return;
      }

      print('📍 [LocationPicker] Getting current position...');
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print(
        '✅ [LocationPicker] Position received: ${position.latitude}, ${position.longitude}',
      );

      final newPos = LatLng(position.latitude, position.longitude);
      setState(() {
        _selectedPosition = newPos;
        _addMarker(newPos);
      });

      if (_mapController != null) {
        print('🗺️ [LocationPicker] Animating camera to new position...');
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(newPos, 15),
        );
      } else {
        print(
          '⚠️ [LocationPicker] Map controller is null, cannot animate camera',
        );
      }

      await _getAddressFromLatLng(newPos);
    } catch (e) {
      print('❌ [LocationPicker] Error getting current location: $e');
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() {
          _selectedAddress = [
            p.name,
            p.street,
            p.locality,
            p.administrativeArea,
          ].where((s) => s != null && s.isNotEmpty).join(', ');
        });
      }
    } catch (e) {
      // ignore
    }
  }

  void _addMarker(LatLng position) {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          draggable: true,
          onDragEnd: (newPos) {
            _selectedPosition = newPos;
            _getAddressFromLatLng(newPos);
          },
        ),
      };
    });
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedPosition = position;
    });
    _addMarker(position);
    _getAddressFromLatLng(position);
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty || !_isMapAvailable) {
      setState(() {
        _searchSuggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    try {
      print('🔍 [LocationPicker] Searching for suggestions: $query');
      final locations = await locationFromAddress(query);

      if (locations.isNotEmpty) {
        setState(() {
          _searchSuggestions = locations.take(5).map((loc) {
            return {
              'latitude': loc.latitude,
              'longitude': loc.longitude,
              'address': query,
            };
          }).toList();
          _showSuggestions = true;
        });

        // Get addresses for each location
        for (int i = 0; i < _searchSuggestions.length; i++) {
          final lat = _searchSuggestions[i]['latitude'];
          final lon = _searchSuggestions[i]['longitude'];
          try {
            final placemarks = await placemarkFromCoordinates(lat, lon);
            if (placemarks.isNotEmpty) {
              final p = placemarks.first;
              setState(() {
                _searchSuggestions[i]['address'] = [
                  p.name,
                  p.street,
                  p.locality,
                  p.administrativeArea,
                  p.country,
                ].where((s) => s != null && s.isNotEmpty).join(', ');
              });
            }
          } catch (e) {
            print('⚠️ Error getting address: $e');
          }
        }
      } else {
        setState(() {
          _searchSuggestions = [];
          _showSuggestions = false;
        });
        print('❌ [LocationPicker] No results found for: $query');
      }
    } catch (e) {
      print('❌ [LocationPicker] Search error: $e');
      setState(() {
        _searchSuggestions = [];
        _showSuggestions = false;
      });
    }
  }

  void _selectSuggestion(Map<String, dynamic> suggestion) {
    final newPos = LatLng(suggestion['latitude'], suggestion['longitude']);

    setState(() {
      _selectedPosition = newPos;
      _selectedAddress = suggestion['address'];
      _showSuggestions = false;
      _searchController.text = suggestion['address'];
    });

    // Use addPostFrameCallback to avoid navigator errors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addMarker(newPos);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(newPos, 15));
    });
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();

    if (query.length >= 3) {
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        if (mounted && _searchController.text == query) {
          _searchLocation(query);
        }
      });
    } else {
      setState(() {
        _searchSuggestions = [];
        _showSuggestions = false;
      });
    }
  }

  void _filterLocations() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredLocations = _mockLocations;
      } else {
        _filteredLocations = _mockLocations
            .where((loc) => loc.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _selectLocation(String location) {
    setState(() => _selectedLocation = location);
  }

  void _confirm() {
    if (_isMapAvailable) {
      if (_selectedAddress.isNotEmpty) {
        // Return a Map with location data for backend
        Navigator.pop(context, {
          'name': _selectedAddress,
          'latitude': _selectedPosition.latitude,
          'longitude': _selectedPosition.longitude,
        });
      }
    } else {
      if (_selectedLocation != null) {
        // Return only name for mock locations
        Navigator.pop(context, {'name': _selectedLocation});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.instance;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.tr('event.create.location_picker_title'),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_isMapAvailable
              ? _selectedAddress.isNotEmpty
              : _selectedLocation != null)
            TextButton(
              onPressed: _confirm,
              child: Text(
                'Done',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  onChanged: _isMapAvailable ? _onSearchChanged : null,
                  onSubmitted: _isMapAvailable ? _searchLocation : null,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search for a place...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchSuggestions = [];
                                _showSuggestions = false;
                              });
                            },
                          )
                        : null,
                  ),
                ),
              ),

              // If Google Maps API key present, show interactive map and search
              if (_isMapAvailable) ...[
                Expanded(
                  child: Stack(
                    children: [
                      GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: CameraPosition(
                          target: _selectedPosition,
                          zoom: 15,
                        ),
                        onMapCreated: (controller) {
                          print('🗺️ [LocationPicker] Google Map created!');
                          _mapController = controller;
                          // Force map to refresh after creation
                          Future.delayed(const Duration(milliseconds: 100), () {
                            if (mounted && _mapController != null) {
                              print(
                                '🗺️ [LocationPicker] Moving camera to initial position: $_selectedPosition',
                              );
                              _mapController!.animateCamera(
                                CameraUpdate.newLatLngZoom(
                                  _selectedPosition,
                                  15,
                                ),
                              );
                            }
                          });
                        },
                        onTap: (pos) => _onMapTap(pos),
                        markers: _markers,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        compassEnabled: true,
                        mapToolbarEnabled: false,
                        rotateGesturesEnabled: true,
                        scrollGesturesEnabled: true,
                        tiltGesturesEnabled: true,
                        zoomGesturesEnabled: true,
                        trafficEnabled: false,
                        buildingsEnabled: true,
                      ),

                      // Selected Address Card with Confirm Button
                      if (_selectedAddress.isNotEmpty)
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _selectedAddress,
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _confirm,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      'Confirm Location',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ] else ...[
                const SizedBox(height: 8),

                // Location List (mock)
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredLocations.length,
                    itemBuilder: (context, index) {
                      final location = _filteredLocations[index];
                      final isSelected = location == _selectedLocation;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.location_on,
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            location,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : null,
                          onTap: () => _selectLocation(location),
                        ),
                      );
                    },
                  ),
                ),

                // Map Preview Placeholder (for future Google Maps integration)
                Container(
                  height: 200,
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map, size: 48, color: Colors.grey[600]),
                        const SizedBox(height: 8),
                        Text(
                          'Map Preview',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Google Maps will appear here',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Suggestions Overlay
          if (_showSuggestions && _searchSuggestions.isNotEmpty)
            Positioned(
              top: 88,
              left: 16,
              right: 16,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _searchSuggestions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final suggestion = _searchSuggestions[index];
                      return ListTile(
                        leading: Icon(
                          Icons.location_on,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(
                          suggestion['address'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                        onTap: () => _selectSuggestion(suggestion),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
