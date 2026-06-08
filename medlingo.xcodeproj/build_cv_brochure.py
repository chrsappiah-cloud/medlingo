from pathlib import Path
from textwrap import wrap

from docx import Document
from docx.enum.section import WD_SECTION
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.shared import Inches, Pt, RGBColor
from reportlab.lib import colors
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import inch
from reportlab.pdfbase.pdfmetrics import stringWidth
from reportlab.platypus import Paragraph
from reportlab.pdfgen import canvas


OUT_DIR = Path("/Applications/medlingo/medlingo.xcodeproj")
DOCX_PATH = OUT_DIR / "Christopher_Appiah_Thompson_CV_Brochure.docx"
PDF_PATH = OUT_DIR / "Christopher_Appiah_Thompson_CV_Brochure.pdf"
AVATAR = Path("/private/tmp/christopher-avatar.png")

NAVY = colors.HexColor("#10233f")
BLUE = colors.HexColor("#315f84")
GOLD = colors.HexColor("#b89248")
INK = colors.HexColor("#20242a")
MUTED = colors.HexColor("#667085")
LIGHT = colors.HexColor("#f5f3ee")
PALE_BLUE = colors.HexColor("#e8eef5")
RULE = colors.HexColor("#d6d8dd")


profile = {
    "name": "Dr Christopher Appiah-Thompson",
    "headline": "Founder, World Class Scholars | Global consultant in disability, mental health and dementia care",
    "location": "Callaghan, New South Wales, Australia",
    "email": "christopher.appiahthompson@myworldclass.org",
    "personal_email": "chrsappiah@gmail.com",
    "phone": "0403138328",
    "links": [
        "christopherappiahthompson.link",
        "worldclassscholars.vercel.app",
        "linkedin.com/in/christopher-appiah-thompson-a2014045",
        "youtube.com/channel/UC2a-_QUygsGAKWzEdKHEP9Q",
        "tiktok.com/@chrsappiah",
    ],
}

sources = [
    "Public profile: christopherappiahthompson.link",
    "World Class Scholars site metadata and public app bundle: worldclassscholars.vercel.app",
    "Public LinkedIn profile extract: au.linkedin.com/in/christopher-appiah-thompson-a2014045",
    "Public portfolio listing: twine.net/WorldClass123",
]

pages = [
    {
        "kicker": "CV Brochure",
        "title": "Dr Christopher Appiah-Thompson",
        "subtitle": "A classic portfolio of scholarship, social justice consultancy, digital product work and humane care innovation.",
        "lead": "Founder of World Class Scholars and multidisciplinary practitioner connecting academic research, frontline care, creative storytelling and practical digital systems.",
        "bullets": [
            "Global consultancy in disability, mental health and dementia care.",
            "Research-informed training, micro-credentials and care-sector learning pathways.",
            "Digital portfolio spanning iOS, web platforms, podcasts, AI art and ethical marketing.",
        ],
        "cover": True,
    },
    {
        "kicker": "Profile",
        "title": "Professional Identity",
        "lead": "Christopher’s public profile presents a scholar-practitioner whose work joins social justice, care systems, technology and culture.",
        "bullets": [
            "Founder, World Class Scholars, a global consultancy championing equity, dignity and social justice in care.",
            "Public LinkedIn profile lists 1K followers, 500+ connections and service offerings in project management, political consulting, healthcare consulting and non-profit consulting.",
            "Professional base: Callaghan, New South Wales, Australia.",
            "Core language of practice: research, lived experience, co-design, trauma-aware communication and inclusive policy.",
        ],
    },
    {
        "kicker": "Contents",
        "title": "Brochure Roadmap",
        "lead": "This 20-page CV brochure is designed as an elegant leave-behind for academic, consultancy, care-sector and digital-product opportunities.",
        "bullets": [
            "Pages 3-6: qualifications, research background and publications.",
            "Pages 7-10: consultancy, teaching, care practice and leadership experience.",
            "Pages 11-15: digital portfolio, apps, platforms, podcasts, marketing and creative production.",
            "Pages 16-20: memberships, awards, impact themes, contact details and source notes.",
        ],
    },
    {
        "kicker": "Academic Qualifications",
        "title": "Education & Formal Study",
        "lead": "Confirmed public records show a strong pathway through political science, governance, social research and community services.",
        "bullets": [
            "Doctor of Philosophy, University of Newcastle, Faculty of Business and Law, listed in public portfolio as January 2017 to October 2021.",
            "Master of Philosophy, University of Bergen, listed as January 2011 to July 2012.",
            "Bachelor of Arts, First Class Honours, University of Ghana, Legon-Accra, listed as January 2005 to May 2009.",
            "Diploma of Community Services, TAFE NSW, listed as January 2025 to July 2025.",
            "Additional public education entries appear on LinkedIn with incomplete institution labels and dates; these are flagged for verification rather than overclaimed.",
        ],
    },
    {
        "kicker": "Research Areas",
        "title": "Scholarship & Intellectual Agenda",
        "lead": "The research profile moves between African politics, peace and conflict studies, religion, electoral integrity, care ethics and the healing potential of creative arts.",
        "bullets": [
            "Political science and international relations, with work on African democracy, electoral disputes and judicial politics.",
            "Peace, conflict and conflict transformation in African religious philosophy.",
            "Care-sector research on dementia, chronic depression, trauma-informed care and non-pharmacological creative interventions.",
            "Contemporary interests include global AI governance, digital learning systems and humane service design.",
        ],
    },
    {
        "kicker": "Publications",
        "title": "Selected Peer-Reviewed Work",
        "lead": "Public LinkedIn records list three selected publications across African politics, peace education and judicial politics.",
        "bullets": [
            "“Adjudicating electoral disputes or judicialising politics? The Supreme Court of Ghana and the disputed 2012 presidential election in perspective,” The Round Table, 17 December 2021.",
            "“The concept of peace, conflict and conflict transformation in African religious philosophy,” Journal of Peace Education, 6 November 2019.",
            "“Electoral politics and democracy in Africa: A critical review of Lindberg’s thesis,” International Area Studies Review, 19 December 2017.",
            "The publication profile supports consultancy work in governance, policy, civic trust and institutional legitimacy.",
        ],
    },
    {
        "kicker": "Professional Experience",
        "title": "Academic, Research & Communications Roles",
        "lead": "Public portfolio records describe teaching, research administration, communications production and digital marketing responsibilities.",
        "bullets": [
            "Digital Marketing Specialist & Communications Producer, World Class Scholars, listed from July 2025 to present.",
            "Podcast Host & Producer, World Class Scholars, listed from July 2025 to present.",
            "Casual Academic in Politics and International Relations, University of Newcastle, Faculty of Business and Law, listed February 2021 to December 2022.",
            "Research Administrator, University College of Communications, listed January 2015 to January 2017.",
        ],
    },
    {
        "kicker": "Teaching",
        "title": "Learning Design & Academic Practice",
        "lead": "The teaching profile is strongest where complex governance, policy and international relations topics need to become accessible to learners.",
        "bullets": [
            "Tutored undergraduate students in politics and international relations.",
            "Developed lecture materials and facilitated student discussion on policy, governance and research topics.",
            "Designs online courses, micro-credentials and bespoke workshops for care and community-service leaders.",
            "Uses a learner-centred approach informed by research, practice, dignity and accessibility.",
        ],
    },
    {
        "kicker": "Consultancy",
        "title": "World Class Scholars",
        "lead": "World Class Scholars is presented publicly as a global consultancy in disability, mental health and dementia care, with a practical focus on humane systems.",
        "bullets": [
            "Advises government, NGOs and aged-care providers on policy, standards and co-design processes.",
            "Centres human rights, lived experience, trauma-aware communication and inclusive service design.",
            "Builds learning pathways for care workers, leaders, families and community organisations.",
            "Combines consultancy, advocacy, education, digital campaigns and creative media.",
        ],
    },
    {
        "kicker": "Care Innovation",
        "title": "Dementia, Mental Health & Creative Arts",
        "lead": "A 2025 public project explores visual and literary arts as healing strategies for people living with dementia.",
        "bullets": [
            "Research focus: visual art, poems and memory narratives as non-pharmacological supports for chronic depression and traumatic conditions.",
            "Emphasises self-esteem, dignity, confidence and quality of life through meaningful creative participation.",
            "Recognises carers as partners in therapeutic relationships and trauma-informed support.",
            "Connects cultural memory, family, work, ageing, death and identity through expressive arts.",
        ],
    },
    {
        "kicker": "Digital Portfolio",
        "title": "Technical & Product Capabilities",
        "lead": "The digital portfolio positions Christopher as a founder and multidisciplinary digital professional across mobile, web, content and platform systems.",
        "bullets": [
            "Technical stack listed publicly: SwiftUI, Firebase, TestFlight workflows, React, Node.js, Python and modern content systems.",
            "Portfolio capabilities include iOS application development, web development, communications strategy, podcast production and service design.",
            "World Class Scholars site includes public routes for library search, courses, podcasts, digital marketing, digital advertising, apps, contact and account access.",
            "The platform model combines member access, subscriptions, analytics, content publishing and public engagement.",
        ],
    },
    {
        "kicker": "iOS & App Store",
        "title": "Apps, TestFlight & Commerce",
        "lead": "World Class Scholars presents an iOS-first digital direction with TestFlight beta pathways, App Store discovery and subscription/commerce concepts.",
        "bullets": [
            "Public site metadata references TestFlight iOS apps and App Store subscriptions.",
            "App concepts surfaced in the public bundle include WCS Commerce, WCS Agentic and WCS Gold Test.",
            "Product examples include premium membership, AI tutor credit packs and specialist tool unlocks.",
            "The product story is strongest when framed as accessible learning and care-sector tooling rather than technology for its own sake.",
        ],
    },
    {
        "kicker": "AI & Future Learning",
        "title": "FutureLab, AI Art & Learning Systems",
        "lead": "Public posts describe World Class Scholars FutureLab as a research-driven gallery and lab at the intersection of AI, sci-fi art and learning.",
        "bullets": [
            "FutureLab themes include neural landscapes, speculative visual narratives, motion studies and future literacies.",
            "WCS Art Verse is presented as a digital gallery for student artwork and curated collections.",
            "Digital art channels include NightCafe and Gumroad creative outputs.",
            "The broader portfolio uses AI as a learning, storytelling and impact-amplification tool.",
        ],
    },
    {
        "kicker": "Podcasts & Media",
        "title": "Audio, Storytelling & Public Scholarship",
        "lead": "The public site and profile list multiple podcast and media projects that translate research and culture for broader audiences.",
        "bullets": [
            "Heartbeats Beyond Memory — Creative Care in Dementia: humane practice, storytelling and community-centred care.",
            "Decoding the Signs and Symbols of Freemasonry in the 21st Century: history, symbolism and contemporary interpretation.",
            "Art, Culture and Philosophies of Tattoos: body art, identity, art history and cultural philosophy.",
            "Production scope includes planning, scripting, hosting, editing, distribution and digital promotion.",
        ],
    },
    {
        "kicker": "Digital Marketing",
        "title": "Campaigns, Content & Brand Systems",
        "lead": "Public portfolio records describe communications campaigns across social media, email and digital platforms.",
        "bullets": [
            "Plans and executes multi-channel communications campaigns to raise organisational profile and reach target audiences.",
            "Manages paid advertising with data-driven optimisation for traffic, leads and conversions.",
            "LinkedIn posts describe AI-enabled tourism marketing using frameworks such as 7Ps, PESTLE, STP, pricing, content and personalisation.",
            "World Class Scholars platform includes digital marketing and digital advertising routes with analytics and referral logic.",
        ],
    },
    {
        "kicker": "Honours & Awards",
        "title": "Awards, Scholarships & Recognition",
        "lead": "The public LinkedIn profile lists academic travel awards and scholarships across Australia, the UK, Scandinavia and African studies contexts.",
        "bullets": [
            "PhD Travel Award Scheme, Australian Political Science Association, July 2019.",
            "Santander Academic Travel Research Award, Santander Bank UK, June 2014.",
            "Nordic African Institute Study Scholarship, March 2012.",
            "Norwegian Quota Program Scholarship, Department of Administration and Organisation Theory, August 2010.",
            "Eni & St Antony’s College Scholarship, listed publicly with incomplete date details.",
        ],
    },
    {
        "kicker": "Memberships",
        "title": "Professional & Research Networks",
        "lead": "The professional memberships reinforce a globally networked research identity across political science, African studies, religion and peace research.",
        "bullets": [
            "Electoral Integrity Project, listed December 2022 to present.",
            "Varieties of Peace Research Network, listed February 2020 to present.",
            "Australian Association for the Study of Religion; Portuguese Political Science Association; Canadian Association of African Studies.",
            "International Studies Association; Australian Political Science Association; American Political Science Association.",
            "International Political Science Association; European Consortium for Political Research.",
        ],
    },
    {
        "kicker": "Services",
        "title": "What Christopher Offers",
        "lead": "The offer is strongest as an integrated package: scholarly credibility, ethical care practice, digital delivery and human-centred communications.",
        "bullets": [
            "Policy and service-design consulting for disability, mental health, dementia care and community services.",
            "Learning design for online courses, micro-credentials, workshops and professional development.",
            "Digital product strategy for accessible apps, member platforms, content systems and AI-enabled learning tools.",
            "Brand storytelling, podcast production, public scholarship and ethical digital marketing for purpose-driven organisations.",
        ],
    },
    {
        "kicker": "Strategic Positioning",
        "title": "Impact Themes",
        "lead": "A cohesive CV narrative emerges around dignity: dignity in public institutions, care relationships, learning environments and digital systems.",
        "bullets": [
            "Equity and social justice: translating scholarship into humane institutional practice.",
            "Care-sector transformation: combining lived experience, trauma awareness and creative engagement.",
            "Digital inclusion: building systems that are accessible, scalable and useful to real communities.",
            "Public scholarship: turning research into podcasts, courses, galleries and tools that travel beyond the academy.",
        ],
    },
    {
        "kicker": "Contact & Verification",
        "title": "Contact, Portfolio Links & Source Notes",
        "lead": "This brochure was prepared from public web, LinkedIn and portfolio material available on 3 June 2026.",
        "bullets": [
            f"Email: {profile['email']} | Personal email: {profile['personal_email']} | Phone: {profile['phone']}",
            "Portfolio: christopherappiahthompson.link | World Class Scholars: worldclassscholars.vercel.app",
            "LinkedIn: linkedin.com/in/christopher-appiah-thompson-a2014045",
            "Verification note: public records contain incomplete labels and at least one conflicting education date; final employer-facing versions should be reconciled against official certificates and a current CV.",
            "Sources used: " + "; ".join(sources) + ".",
        ],
    },
]


def fit_text(c, text, font, size, x, y, max_width, leading, color=INK, bold=False):
    name = f"{font}-Bold" if bold else font
    c.setFont(name, size)
    c.setFillColor(color)
    lines = []
    for para in str(text).split("\n"):
        words = para.split()
        current = ""
        for word in words:
            candidate = (current + " " + word).strip()
            if stringWidth(candidate, name, size) <= max_width:
                current = candidate
            else:
                if current:
                    lines.append(current)
                current = word
        if current:
            lines.append(current)
    for line in lines:
        c.drawString(x, y, line)
        y -= leading
    return y


def wrapped_lines(text, font_name, size, max_width):
    lines = []
    for para in str(text).split("\n"):
        words = para.split()
        current = ""
        for word in words:
            candidate = (current + " " + word).strip()
            if stringWidth(candidate, font_name, size) <= max_width:
                current = candidate
            else:
                if current:
                    lines.append(current)
                current = word
        if current:
            lines.append(current)
    return lines


def pill(c, x, y, text, fill=PALE_BLUE, stroke=RULE):
    c.setFillColor(fill)
    c.setStrokeColor(stroke)
    c.roundRect(x, y - 16, stringWidth(text, "Helvetica", 8.5) + 18, 20, 5, stroke=1, fill=1)
    c.setFont("Helvetica", 8.5)
    c.setFillColor(NAVY)
    c.drawString(x + 9, y - 11, text)


def draw_pdf_page(c, page, idx):
    width, height = letter
    c.setFillColor(colors.white)
    c.rect(0, 0, width, height, fill=1, stroke=0)
    c.setFillColor(LIGHT)
    c.rect(0, height - 0.84 * inch, width, 0.84 * inch, fill=1, stroke=0)
    c.setFillColor(NAVY)
    c.rect(0, height - 0.84 * inch, 0.18 * inch, 0.84 * inch, fill=1, stroke=0)
    c.setStrokeColor(GOLD)
    c.setLineWidth(1.2)
    c.line(0.78 * inch, height - 0.68 * inch, width - 0.78 * inch, height - 0.68 * inch)
    c.setFont("Helvetica-Bold", 8.5)
    c.setFillColor(GOLD)
    c.drawString(0.82 * inch, height - 0.49 * inch, page["kicker"].upper())
    c.setFont("Helvetica", 8.3)
    c.setFillColor(MUTED)
    c.drawRightString(width - 0.78 * inch, height - 0.49 * inch, f"{idx:02d} / 20")

    if page.get("cover"):
        c.setFillColor(NAVY)
        c.rect(0, 0, width, height - 0.84 * inch, fill=1, stroke=0)
        c.setFillColor(GOLD)
        c.rect(0.7 * inch, 0.8 * inch, 0.05 * inch, height - 2.2 * inch, fill=1, stroke=0)
        if AVATAR.exists():
            c.drawImage(str(AVATAR), width - 2.35 * inch, height - 3.0 * inch, 1.6 * inch, 1.6 * inch, mask="auto")
        c.setFont("Helvetica-Bold", 9)
        c.setFillColor(GOLD)
        c.drawString(0.92 * inch, height - 1.58 * inch, "CURRICULUM VITAE BROCHURE")
        y = height - 2.02 * inch
        y = fit_text(c, page["title"], "Helvetica", 34, 0.92 * inch, y, 4.7 * inch, 39, colors.white, bold=True)
        y -= 0.16 * inch
        y = fit_text(c, page["subtitle"], "Helvetica", 13.5, 0.94 * inch, y, 4.75 * inch, 18, colors.HexColor("#e6edf5"))
        y -= 0.28 * inch
        y = fit_text(c, page["lead"], "Helvetica", 10.5, 0.94 * inch, y, 4.7 * inch, 15, colors.HexColor("#d8dee8"))
        y -= 0.12 * inch
        for b in page["bullets"]:
            c.setFillColor(GOLD)
            c.circle(0.98 * inch, y + 3, 2.2, fill=1, stroke=0)
            fit_text(c, b, "Helvetica", 9.5, 1.12 * inch, y, 4.7 * inch, 13.5, colors.white)
            y -= 0.48 * inch
        c.setFont("Helvetica", 8.5)
        c.setFillColor(colors.HexColor("#cbd5e1"))
        c.drawString(0.92 * inch, 0.72 * inch, "Prepared from public web, LinkedIn and portfolio material | 3 June 2026")
        c.showPage()
        return

    x = 0.82 * inch
    y = height - 1.35 * inch
    y = fit_text(c, page["title"], "Helvetica", 24, x, y, 6.3 * inch, 28, NAVY, bold=True)
    y -= 0.12 * inch
    y = fit_text(c, page["lead"], "Helvetica", 11, x, y, 6.25 * inch, 15, INK)
    y -= 0.26 * inch

    c.setStrokeColor(RULE)
    c.setLineWidth(0.8)
    c.line(x, y + 0.06 * inch, width - 0.82 * inch, y + 0.06 * inch)
    y -= 0.24 * inch

    for i, b in enumerate(page["bullets"]):
        lines = wrapped_lines(b, "Helvetica", 9.7, 5.72 * inch)
        box_h = max(0.56 * inch, (len(lines) * 12.5) + 0.24 * inch)
        box_y = y + 0.06 * inch
        c.setFillColor(colors.HexColor("#fbfbfa") if i % 2 == 0 else colors.white)
        c.setStrokeColor(RULE)
        c.roundRect(x, box_y - box_h, 6.2 * inch, box_h - 0.04 * inch, 4, stroke=1, fill=1)
        c.setFillColor(GOLD)
        c.circle(x + 0.18 * inch, box_y - 0.22 * inch, 3, fill=1, stroke=0)
        text_y = box_y - 0.16 * inch
        c.setFont("Helvetica", 9.7)
        c.setFillColor(INK)
        for line in lines:
            c.drawString(x + 0.36 * inch, text_y, line)
            text_y -= 12.5
        y -= box_h + 0.14 * inch

    if idx in (4, 7, 11, 14, 18):
        pill(c, x, 1.0 * inch, "Scholarship")
        pill(c, x + 1.25 * inch, 1.0 * inch, "Consultancy")
        pill(c, x + 2.55 * inch, 1.0 * inch, "Digital portfolio")
        pill(c, x + 4.08 * inch, 1.0 * inch, "Care innovation")

    c.setStrokeColor(GOLD)
    c.setLineWidth(0.8)
    c.line(0.82 * inch, 0.55 * inch, width - 0.82 * inch, 0.55 * inch)
    c.setFont("Helvetica", 7.5)
    c.setFillColor(MUTED)
    c.drawString(0.82 * inch, 0.38 * inch, "Dr Christopher Appiah-Thompson | CV Brochure")
    c.drawRightString(width - 0.82 * inch, 0.38 * inch, "World Class Scholars")
    c.showPage()


def make_pdf():
    c = canvas.Canvas(str(PDF_PATH), pagesize=letter)
    for idx, page in enumerate(pages, start=1):
        draw_pdf_page(c, page, idx)
    c.save()


def set_docx_font(run, size=None, color=None, bold=None):
    run.font.name = "Calibri"
    if size:
        run.font.size = Pt(size)
    if color:
        run.font.color.rgb = RGBColor(*color)
    if bold is not None:
        run.bold = bold


def make_docx():
    doc = Document()
    section = doc.sections[0]
    section.page_width = Inches(8.5)
    section.page_height = Inches(11)
    for sec in doc.sections:
        sec.top_margin = Inches(0.75)
        sec.bottom_margin = Inches(0.7)
        sec.left_margin = Inches(0.8)
        sec.right_margin = Inches(0.8)

    styles = doc.styles
    styles["Normal"].font.name = "Calibri"
    styles["Normal"].font.size = Pt(10.5)

    for idx, page in enumerate(pages, start=1):
        if idx > 1:
            doc.add_page_break()
        p = doc.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
        r = p.add_run(f"{idx:02d} / 20  |  {page['kicker'].upper()}")
        set_docx_font(r, 8, (102, 112, 133), True)

        if page.get("cover") and AVATAR.exists():
            imgp = doc.add_paragraph()
            imgp.alignment = WD_ALIGN_PARAGRAPH.RIGHT
            imgp.add_run().add_picture(str(AVATAR), width=Inches(1.25))

        title = doc.add_paragraph()
        title.paragraph_format.space_after = Pt(8)
        tr = title.add_run(page["title"])
        set_docx_font(tr, 24 if page.get("cover") else 20, (16, 35, 63), True)

        sub = page.get("subtitle")
        if sub:
            p = doc.add_paragraph()
            sr = p.add_run(sub)
            set_docx_font(sr, 12, (49, 95, 132), True)

        p = doc.add_paragraph()
        lr = p.add_run(page["lead"])
        set_docx_font(lr, 10.5, (32, 36, 42), False)

        for bullet in page["bullets"]:
            bp = doc.add_paragraph(style=None)
            bp.paragraph_format.left_indent = Inches(0.22)
            bp.paragraph_format.first_line_indent = Inches(-0.22)
            bp.paragraph_format.space_after = Pt(7)
            br = bp.add_run("• ")
            set_docx_font(br, 10.5, (184, 146, 72), True)
            tx = bp.add_run(bullet)
            set_docx_font(tx, 10.2, (32, 36, 42), False)

    doc.save(DOCX_PATH)


if __name__ == "__main__":
    make_pdf()
    make_docx()
    print(DOCX_PATH)
    print(PDF_PATH)
