import 'package:flutter/material.dart';
import '../models/farm_model.dart';
import '../services/kml_service.dart';
import '../widgets/farm_card.dart';
import 'overview_map_screen.dart';

class FarmListScreen
    extends
        StatefulWidget {
  const FarmListScreen({
    super.key,
  });

  @override
  State<
    FarmListScreen
  >
  createState() => _FarmListScreenState();
}

class _FarmListScreenState
    extends
        State<
          FarmListScreen
        > {
  final String _myMapsId = '16V-t8nIWuYbt5LpNzJYxa_TDshAZCiA';
  final TextEditingController _searchController = TextEditingController();

  List<
    FarmModel
  >
  _farms = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _searchQuery = '';
  String _selectedSort = 'name_asc';

  @override
  void initState() {
    super.initState();
    _loadAllFarmsFromMap();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<
    void
  >
  _loadAllFarmsFromMap() async {
    setState(
      () {
        _isLoading = true;
        _errorMessage = null;
      },
    );

    try {
      final fetchedFarms = await KmlService.fetchMyMapsFarms(
        _myMapsId,
      );
      setState(
        () {
          _farms = fetchedFarms;
          _isLoading = false;
        },
      );
    } catch (
      e
    ) {
      setState(
        () {
          _errorMessage = e.toString().replaceAll(
            'Exception: ',
            '',
          );
          _isLoading = false;
        },
      );
    }
  }

  /// Computes filtered and sorted farm list using `FarmModel.areaInHectares`
  List<
    FarmModel
  >
  get _filteredAndSortedFarms {
    List<
      FarmModel
    >
    list = _farms.where(
      (
        farm,
      ) {
        final name = farm.name.toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(
          query,
        );
      },
    ).toList();

    list.sort(
      (
        a,
        b,
      ) {
        switch (_selectedSort) {
          case 'name_asc':
            return a.name.toLowerCase().compareTo(
              b.name.toLowerCase(),
            );
          case 'name_desc':
            return b.name.toLowerCase().compareTo(
              a.name.toLowerCase(),
            );
          case 'size_asc':
            return a.areaInHectares.compareTo(
              b.areaInHectares,
            );
          case 'size_desc':
            return b.areaInHectares.compareTo(
              a.areaInHectares,
            );
          default:
            return 0;
        }
      },
    );

    return list;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final displayFarms = _filteredAndSortedFarms;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Farms (${_farms.length} farms)',
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.map_outlined,
            ),
            tooltip: 'Overview Map',
            onPressed: _farms.isEmpty
                ? null
                : () {
                    Navigator.of(
                      context,
                    ).push(
                      MaterialPageRoute(
                        builder:
                            (
                              _,
                            ) => OverviewMapScreen(
                              farms: _farms,
                            ),
                      ),
                    );
                  },
          ),
          IconButton(
            icon: const Icon(
              Icons.refresh,
            ),
            onPressed: _loadAllFarmsFromMap,
            tooltip: 'Sync Map Layers',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _errorMessage !=
                null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(
                  24.0,
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Column(
              children: [
                // Search & Filter Controls Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    8,
                  ),
                  child: Row(
                    children: [
                      // Dynamic Search Bar
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search farm name...',
                            prefixIcon: const Icon(
                              Icons.search,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(
                                        () {
                                          _searchQuery = '';
                                        },
                                      );
                                    },
                                  )
                                : null,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                10,
                              ),
                            ),
                          ),
                          onChanged:
                              (
                                value,
                              ) {
                                setState(
                                  () {
                                    _searchQuery = value;
                                  },
                                );
                              },
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),

                      // Sort Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade400,
                          ),
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child:
                              DropdownButton<
                                String
                              >(
                                value: _selectedSort,
                                icon: const Icon(
                                  Icons.sort,
                                ),
                                hint: const Text(
                                  'Sort',
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'name_asc',
                                    child: Text(
                                      'Name (A - Z)',
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'name_desc',
                                    child: Text(
                                      'Name (Z - A)',
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'size_asc',
                                    child: Text(
                                      'Size (Smallest)',
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'size_desc',
                                    child: Text(
                                      'Size (Largest)',
                                    ),
                                  ),
                                ],
                                onChanged:
                                    (
                                      value,
                                    ) {
                                      if (value !=
                                          null) {
                                        setState(
                                          () {
                                            _selectedSort = value;
                                          },
                                        );
                                      }
                                    },
                              ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Content Section
                Expanded(
                  child: displayFarms.isEmpty
                      ? Center(
                          child: Text(
                            _searchQuery.isEmpty
                                ? 'No farms available.'
                                : 'No farms found matching "$_searchQuery"',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : LayoutBuilder(
                          builder:
                              (
                                context,
                                constraints,
                              ) {
                                final double screenWidth = constraints.maxWidth;
                                final int crossAxisCount =
                                    screenWidth >
                                        1100
                                    ? 3
                                    : (screenWidth >
                                              700
                                          ? 2
                                          : 1);

                                return RefreshIndicator(
                                  onRefresh: _loadAllFarmsFromMap,
                                  child:
                                      crossAxisCount ==
                                          1
                                      ? ListView.builder(
                                          padding: const EdgeInsets.all(
                                            16,
                                          ),
                                          itemCount: displayFarms.length,
                                          itemBuilder:
                                              (
                                                context,
                                                index,
                                              ) {
                                                return Padding(
                                                  padding: const EdgeInsets.only(
                                                    bottom: 16,
                                                  ),
                                                  child: FarmCard(
                                                    farm: displayFarms[index],
                                                  ),
                                                );
                                              },
                                        )
                                      : GridView.builder(
                                          padding: const EdgeInsets.all(
                                            16,
                                          ),
                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: crossAxisCount,
                                            crossAxisSpacing: 16,
                                            mainAxisSpacing: 16,
                                            mainAxisExtent: 330,
                                          ),
                                          itemCount: displayFarms.length,
                                          itemBuilder:
                                              (
                                                context,
                                                index,
                                              ) {
                                                return FarmCard(
                                                  farm: displayFarms[index],
                                                );
                                              },
                                        ),
                                );
                              },
                        ),
                ),
              ],
            ),
    );
  }
}
