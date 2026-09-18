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
  List<
    FarmModel
  >
  _farms = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAllFarmsFromMap();
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

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Farms',
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
                              itemCount: _farms.length,
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
                                        farm: _farms[index],
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
                              itemCount: _farms.length,
                              itemBuilder:
                                  (
                                    context,
                                    index,
                                  ) {
                                    return FarmCard(
                                      farm: _farms[index],
                                    );
                                  },
                            ),
                    );
                  },
            ),
    );
  }
}
