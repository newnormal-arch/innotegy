import 'package:flutter/material.dart';

class SharedAuthLayout
    extends
        StatelessWidget {
  final Widget formSection;

  const SharedAuthLayout({
    super.key,
    required this.formSection,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder:
            (
              context,
              constraints,
            ) {
              final bool isMobile =
                  constraints.maxWidth <
                  900;

              if (isMobile) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 380,
                        child: HeroImageSection(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(
                          24.0,
                        ),
                        child: formSection,
                      ),
                    ],
                  ),
                );
              }

              return Row(
                children: [
                  const Expanded(
                    flex: 11,
                    child: HeroImageSection(),
                  ),
                  Expanded(
                    flex: 9,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48.0,
                          vertical: 32.0,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 440,
                            ),
                            child: formSection,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
      ),
    );
  }
}

class HeroImageSection
    extends
        StatelessWidget {
  const HeroImageSection({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1600&q=80',
          fit: BoxFit.cover,
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(
                  alpha: 0.3,
                ),
                Colors.black.withValues(
                  alpha: 0.75,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(
            40.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/logo.png',
                width: 300,
              ),
              const Spacer(),
              const Text(
                'Empowering the next\ngeneration of\nagriculture.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  height: 1.15,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                'Join thousands of farms worldwide using AgriManage to optimize yields, track sustainability, and collaborate with experts in real-time.',
                style: TextStyle(
                  color: Colors.white.withValues(
                    alpha: 0.85,
                  ),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(
                height: 32,
              ),
              const Divider(
                color: Colors.white24,
                height: 1,
              ),
              const SizedBox(
                height: 32,
              ),
              const Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      value: '10+',
                      label: 'ACTIVE FARMS',
                    ),
                  ),
                  Expanded(
                    child: _StatTile(
                      value: '98%',
                      label: 'COMPLIANCE RATE',
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '© 2026 Innotegy Solutions Inc.  •  Privacy  •  Global Operations',
                style: TextStyle(
                  color: Colors.white.withValues(
                    alpha: 0.6,
                  ),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatTile
    extends
        StatelessWidget {
  final String value;
  final String label;

  const _StatTile({
    required this.value,
    required this.label,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(
              alpha: 0.7,
            ),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
