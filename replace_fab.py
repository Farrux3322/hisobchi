import pathlib

file_path = pathlib.Path('lib/presentation/pages/client/client_list_page.dart')
text = file_path.read_text()

if "import 'dart:ui';" not in text:
    text = text.replace("import 'package:flutter/material.dart';", "import 'dart:ui';\nimport 'package:flutter/material.dart';")

fab_start_report = """                    SizedBox(
                      width: 56.w,
                      height: 56.w,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18.r),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: FloatingActionButton(
                            tooltip: "Mijozlar hisoboti",
                            heroTag: 'client_report_fab',
                            elevation: 0,
                            focusElevation: 0,
                            hoverElevation: 0,
                            highlightElevation: 0,"""

text = text.replace(
"""                    SizedBox(
                      width: 56.w,
                      height: 56.w,
                      child: FloatingActionButton(
                        tooltip: "Mijozlar hisoboti",
                        heroTag: 'client_report_fab',
                        elevation: 4,""",
fab_start_report)

fab_end_report = """                        backgroundColor: AppTheme.colors.primary.withValues(alpha: 0.7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.r),
                          side: BorderSide(
                            color: Colors.white.withValues(
                              alpha: 0.3,
                            ),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.analytics_rounded,
                          color: AppTheme.colors.white,
                          size: 28.sp,
                        ),
                      ),
                    ),
                  ),"""

text = text.replace(
"""                        backgroundColor: AppTheme.colors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.r),
                          side: BorderSide(
                            color: AppTheme.colors.primary.withValues(
                              alpha: 0.1,
                            ),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.analytics_rounded,
                          color: AppTheme.colors.white,
                          size: 28.sp,
                        ),
                      ),
                    ),""",
fab_end_report)

fab_start_add = """                    SizedBox(
                      width: 56.w,
                      height: 56.w,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18.r),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: FloatingActionButton(
                            heroTag: 'client_fab',
                            elevation: 0,
                            focusElevation: 0,
                            hoverElevation: 0,
                            highlightElevation: 0,"""

text = text.replace(
"""                    SizedBox(
                      width: 56.w,
                      height: 56.w,
                      child: FloatingActionButton(
                        heroTag: 'client_fab',
                        elevation: 4,""",
fab_start_add)

fab_end_add = """                        backgroundColor: AppTheme.colors.primary.withValues(alpha: 0.7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.r),
                          side: BorderSide(
                            color: Colors.white.withValues(
                              alpha: 0.3,
                            ),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 36.sp,
                        ),
                      ),
                    ),
                  ),"""

text = text.replace(
"""                        backgroundColor: AppTheme.colors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 36.sp,
                        ),
                      ),
                    ),""",
fab_end_add)

file_path.write_text(text)
print("Transformation Complete")
