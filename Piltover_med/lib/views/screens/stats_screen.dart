import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // Medical terms data (keeping your existing data)
  List<Map<String, String>> _allTerms = [
    {
      "term": "B12",
      "meaning": "A vitamin essential for nerve function and the production of red blood cells.",
      "adults": "200-900 pg/mL (optimal: >300 pg/mL)",
      "children": "200-900 pg/mL",
      "elderly": "200-900 pg/mL (may need supplementation)"
    },
    {
      "term": "BMI",
      "meaning": "Body Mass Index, a measure of body fat based on height and weight.",
      "adults": "Normal: 18.5-24.9 | Overweight: 25-29.9 | Obese: ≥30",
      "children": "Uses percentile charts (age and gender specific)",
      "elderly": "Normal: 23-28 (slightly higher range acceptable)"
    },
    {
      "term": "Blood Pressure",
      "meaning": "The force of blood pushing against the walls of your arteries as your heart pumps.",
      "adults": "Normal: <120/80 mmHg | Elevated: 120-129/<80 | High: ≥130/80",
      "children": "Varies by age, height, and gender (percentile-based)",
      "elderly": "May be slightly higher: <130/80 mmHg (acceptable)"
    },
    {
      "term": "Calcium",
      "meaning": "A mineral that builds strong bones and teeth, and helps muscles and nerves function.",
      "adults": "8.5-10.5 mg/dL",
      "children": "8.8-10.8 mg/dL (slightly higher)",
      "elderly": "8.5-10.5 mg/dL (may need supplementation)"
    },
    {
      "term": "Creatinine",
      "meaning": "A waste product that comes from normal wear and tear on muscles of the body, filtered by kidneys.",
      "adults": "Men: 0.7-1.3 mg/dL | Women: 0.6-1.1 mg/dL",
      "children": "0.3-0.7 mg/dL (varies with age and muscle mass)",
      "elderly": "May be slightly higher: 0.8-1.5 mg/dL"
    },
    {
      "term": "Glucose",
      "meaning": "The main type of sugar in the blood and the major source of energy for the body's cells.",
      "adults": "Fasting: 70-100 mg/dL | Random: <140 mg/dL",
      "children": "Fasting: 70-100 mg/dL | Similar to adults",
      "elderly": "Fasting: 70-110 mg/dL | May be slightly higher"
    },
    {
      "term": "HDL",
      "meaning": "High-Density Lipoprotein, often called 'good cholesterol' that helps remove bad cholesterol from your arteries.",
      "adults": "Men: >40 mg/dL | Women: >50 mg/dL (higher is better)",
      "children": ">40 mg/dL",
      "elderly": ">40 mg/dL (men), >50 mg/dL (women)"
    },
    {
      "term": "Hemoglobin",
      "meaning": "The protein in red blood cells that carries oxygen.",
      "adults": "Men: 13.5-17.5 g/dL | Women: 12.0-15.5 g/dL",
      "children": "Varies by age: 11-13 g/dL (6-12 years) | 12-14 g/dL (12-18 years)",
      "elderly": "May be slightly lower: 12.0-16.0 g/dL"
    },
    {
      "term": "Hemoglobin A1C",
      "meaning": "A test that shows your average blood sugar level over the past 2-3 months.",
      "adults": "Normal: <5.7% | Prediabetes: 5.7-6.4% | Diabetes: ≥6.5%",
      "children": "Normal: <5.7% | Similar to adults",
      "elderly": "Normal: <5.7% | May target <7.0% if other health issues"
    },
    {
      "term": "Iron",
      "meaning": "A mineral needed to make hemoglobin, which carries oxygen in your blood.",
      "adults": "Men: 65-175 μg/dL | Women: 50-170 μg/dL",
      "children": "50-120 μg/dL",
      "elderly": "50-150 μg/dL"
    },
    {
      "term": "LDL",
      "meaning": "Low-Density Lipoprotein, often called 'bad cholesterol' that can build up in arteries.",
      "adults": "Optimal: <100 mg/dL | Near optimal: 100-129 mg/dL | Borderline: 130-159 mg/dL",
      "children": "<110 mg/dL",
      "elderly": "<100 mg/dL (optimal) | <130 mg/dL (acceptable)"
    },
    {
      "term": "Lipid Panel",
      "meaning": "A group of tests that measure fats (cholesterol) in your blood.",
      "adults": "Total Cholesterol: <200 mg/dL | HDL: >40 mg/dL (men), >50 mg/dL (women) | LDL: <100 mg/dL",
      "children": "Total Cholesterol: <170 mg/dL | LDL: <110 mg/dL",
      "elderly": "Similar to adults, but may have slightly higher acceptable ranges"
    },
    {
      "term": "Platelets",
      "meaning": "Tiny blood cells that help your body form clots to stop bleeding.",
      "adults": "150,000-450,000 per microliter",
      "children": "150,000-450,000 per microliter",
      "elderly": "150,000-450,000 per microliter"
    },
    {
      "term": "Potassium",
      "meaning": "A mineral that helps your muscles and nerves work properly.",
      "adults": "3.5-5.0 mEq/L",
      "children": "3.5-5.0 mEq/L",
      "elderly": "3.5-5.0 mEq/L (monitor closely)"
    },
    {
      "term": "RBC",
      "meaning": "Red Blood Cell count. These cells carry oxygen throughout your body.",
      "adults": "Men: 4.5-5.9 million/μL | Women: 4.1-5.1 million/μL",
      "children": "Varies by age: 4.0-5.5 million/μL",
      "elderly": "May be slightly lower: 4.0-5.0 million/μL"
    },
    {
      "term": "Sodium",
      "meaning": "A mineral that helps control fluid balance in your body, but too much can raise blood pressure.",
      "adults": "136-145 mEq/L",
      "children": "136-145 mEq/L",
      "elderly": "136-145 mEq/L (may be slightly lower)"
    },
    {
      "term": "Triglycerides",
      "meaning": "A type of fat in your blood that can increase heart disease risk if too high.",
      "adults": "Normal: <150 mg/dL | Borderline: 150-199 mg/dL | High: ≥200 mg/dL",
      "children": "<90 mg/dL (optimal)",
      "elderly": "<150 mg/dL (similar to adults)"
    },
    {
      "term": "TSH",
      "meaning": "Thyroid Stimulating Hormone. It controls how your thyroid works.",
      "adults": "0.4-4.0 mIU/L",
      "children": "Varies by age: 0.7-6.4 mIU/L (newborns) | 0.7-5.0 mIU/L (children)",
      "elderly": "0.4-5.0 mIU/L (may be slightly higher)"
    },
    {
      "term": "Vitamin D",
      "meaning": "A vitamin that helps your body absorb calcium and maintain strong bones.",
      "adults": "30-100 ng/mL (optimal: 40-60 ng/mL)",
      "children": "30-100 ng/mL",
      "elderly": "30-100 ng/mL (may need supplementation)"
    },
    {
      "term": "WBC",
      "meaning": "White Blood Cell count. These cells help fight infections in your body.",
      "adults": "4,500-11,000 per microliter",
      "children": "5,000-15,000 per microliter (higher in infants)",
      "elderly": "4,000-10,000 per microliter (may be slightly lower)"
    },
  ];

  List<Map<String, String>> _filteredTerms = [];

  @override
  void initState() {
    super.initState();
    _allTerms.sort((a, b) => a["term"]!.compareTo(b["term"]!));
    _filteredTerms = _allTerms;
  }

  void _filterSearch(String query) {
    setState(() {
      _filteredTerms = _allTerms
          .where((item) => item["term"]!.toLowerCase().contains(query.toLowerCase()))
          .toList();
      _filteredTerms.sort((a, b) => a["term"]!.compareTo(b["term"]!));
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24.0),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0EA5E9).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.menu_book,
                          color: Color(0xFF0EA5E9),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Medical Dictionary',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: _filterSearch,
                    decoration: InputDecoration(
                      hintText: 'Search medical terms...',
                      hintStyle: GoogleFonts.inter(
                        color: const Color(0xFF94A3B8),
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF64748B),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF0EA5E9),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    style: GoogleFonts.inter(
                      color: const Color(0xFF1E293B),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // Terms List
            Expanded(
              child: _filteredTerms.isEmpty
                  ? Center(
                      child: Text(
                        'No terms found',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredTerms.length,
                      itemBuilder: (context, index) {
                        final term = _filteredTerms[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              dividerColor: Colors.transparent,
                            ),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              childrenPadding: const EdgeInsets.all(16),
                              collapsedIconColor: const Color(0xFF0EA5E9),
                              iconColor: const Color(0xFF0EA5E9),
                              title: Text(
                                term["term"]!,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Description
                                      Text(
                                        term["meaning"]!,
                                        style: GoogleFonts.inter(
                                          color: const Color(0xFF64748B),
                                          fontSize: 14,
                                          height: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      // Normal Values
                                      Text(
                                        'Normal Values',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF0EA5E9),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      if (term["adults"] != null)
                                        _buildValueRow('Adults', term["adults"]!),
                                      if (term["children"] != null)
                                        _buildValueRow('Children', term["children"]!),
                                      if (term["elderly"] != null)
                                        _buildValueRow('Elderly (65+)', term["elderly"]!),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                color: const Color(0xFF64748B),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Backward compatibility
class StatsScreen extends DictionaryScreen {
  const StatsScreen({super.key});
}