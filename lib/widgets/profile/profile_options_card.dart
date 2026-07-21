import 'package:flutter/material.dart';

class ProfileOption {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool hasSwitch;
  final bool switchValue;

  ProfileOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.hasSwitch = false,
    this.switchValue = false,
  });
}

class ProfileOptionsCard extends StatelessWidget {
  final List<ProfileOption> options;

  const ProfileOptionsCard({
    super.key,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFD9E5D8),
        ),
      ),
      child: Column(
        children: List.generate(options.length, (index) {
          final item = options[index];

          return Column(
            children: [

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),

                child: Row(
                  children: [

                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEAF2FF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.icon,
                        color: const Color(0xFF006E2F),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            item.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            item.subtitle,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),

                    item.hasSwitch
                        ? Switch(
                      value: item.switchValue,
                      activeThumbColor: const Color(0xFF22C55E),
                      onChanged: (value) {},
                    )
                        : const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),

              if (index != options.length - 1)
                const Divider(
                  height: 1,
                  indent: 24,
                  endIndent: 24,
                ),
            ],
          );
        }),
      ),
    );
  }
}